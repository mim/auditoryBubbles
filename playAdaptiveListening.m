function playAdaptiveListening(cleanWavDir, outDir, subjectName, nRound, ...
    initialBps, dur_s, snr_db, noiseShape, normalize, allowRepeats, ...
    giveFeedback, vertical, globalBps, allowIdk)

% Play adaptive listening test, save mixes and results
%
% playAdaptiveListening(cleanWavDir, outDir, subjectName, nRound, initialBps, dur_s, snr_db, noiseShape, normalize, allowRepeats, giveFeedback, vertical, globalBps)
%
% Adapt the bubbles-per-second level per stimulus using a weighted up/down
% procedure to achieve approximately 0.5*(1 + 1/N) accuracy.  Resulting
% noisy and clean wav  files are stored in outDir along with mat files
% containing useful information for analyzing them.  Results are saved in
% outDir/subjectName.csv.  Presentation of stimuli are blocked so that each
% round contains one presentation of each in a random order. Resulting csv
% file can then be analyzed by processListeningData.  Cumulative results
% for each subject name are saved in the same file, so using the same name
% with the same output directory will add to that file.
%
% Input arguments:
%   cleanWavDir    Directory containing clean input wav files to be used
%   outDir         Base directory of output wavs and data
%   subjectName    Identifier for player, cumulative results saved in corresponding csv file
%   nRound         Number of rounds to play (clean file repetitions)
%   initialBps     Initial number of bubbles per second for all stimuli
%   dur_s          Minimum duration to enforce for each file by zero padding
%   snr_db         Signal-to-noise ratio to use in mixtures (usuall around -25)
%   noiseShape     Identified of noise as used by speechProfile.m
%   normalize      If 1, normalize all stimuli to have the same RMS
%   allowRepeats   If 1, listener can play final file multiple times
%   giveFeedback   If 1, tell listener whether they got each guess correct
%   vertical       If 1, show choices vertically, otherwise tab-separated
%   globalBps      If 1, use the same BPS for all stimuli, otherwise use separate bps for each stimulus
%   allowIdk       If 1, allow "[don't know]" response


if ~exist('allowRepeats', 'var') || isempty(allowRepeats), allowRepeats = false; end
if ~exist('giveFeedback', 'var') || isempty(giveFeedback), giveFeedback = false; end
if ~exist('vertical', 'var') || isempty(vertical), vertical = false; end
if ~exist('globalBps', 'var') || isempty(globalBps), globalBps = false; end
if ~exist('allowIdk', 'var') || isempty(allowIdk), allowIdk = false; end

roundsPerBlock = 4;

targetFs = -1;
useHoles = true;
snr = 10^(snr_db/20);

outMixDir = fullfile(outDir, ['bps' subjectName]);
outCleanDir = fullfile(outDir, 'bpsInf');
outCsvFile = fullfile(outDir, [subjectName '.csv']);

[files,paths] = findFiles(cleanWavDir, '.*.wav');
nF = length(files);

rightAnswers = listMap(@figureOutRightAnswerFromFileName, files);
choices = unique(rightAnswers)';
if length(choices) ~= 6
    % warning('Using %d choices instead of 6', length(choices))
end
totCorrect = 0; totIncorrect = 0;
targetCorrectness = 0.5 * (1 + 1 / length(choices));
num = ones(size(files));

if allowIdk
    % Do this after setting targetCorrectness so it doesn't count
    choices{end+1} = '[don''t know]';
end
choiceNums = 1:length(choices);

% Should be compatible with saved files because files cell array is sorted
if isempty(initialBps)
    % Load initialBps from most recently saved mat file from last
    % experiment
    for f = 1:length(files)
        bn = basename(files{f}, 0);
        [~,num(f),~,lastFile{f}] = nextAvailableFile(outMixDir, ...
            '%s_bps%s_snr%+d_%03d', {bn, subjectName, snr_db}, num(f), '.wav');
    end
    for f = 1:length(lastFile)
        d = dir(strrep(lastFile{f}, '.wav', '.mat'));
        if isempty(d)
            dates(f) = -inf;
        else
            dates(f) = d.datenum;
        end
    end
    if ~any(isfinite(dates))
        error('No existing data found in %s, please specify an initialBps value', outMixDir)
    end
    [~,latest] = max(dates);
    d = load(strrep(lastFile{latest}, '.wav', '.mat'));
    perStimBps = d.perStimBps;
    
    fprintf('Resuming experiment using per-stim bps:\n')
    for i = 1:length(files)
        fprintf('%s: %g\n', files{i}, perStimBps(i));
    end
    fprintf('\n');

    trialsDone = sum(num-1);
    roundsDone = floor(trialsDone / length(files));
    nRound = nRound - roundsDone;
    if nRound <= 0
        fprintf('Already completed %d trials = %d rounds, done\n', ...
            trialsDone, roundsDone)
        return
    else
        fprintf('Already completed %d trials = %d rounds, doing %d more rounds\n', ...
            trialsDone, roundsDone, nRound)
    end    
elseif length(initialBps) == 1
    perStimBps = initialBps * ones(size(files));

elseif length(initialBps) == length(files)
    perStimBps = initialBps;
    fprintf('Using per-stim bps:\n')
    for i = 1:length(files)
        fprintf('%s: %g\n', files{i}, perStimBps(i));
    end
    fprintf('\n');

else
    error('Incompatible number of initialBps values: %s, expected %s', ...
        length(initialBps), length(files))
end
perStimPast = [];

if ~exist(outCsvFile, 'file')
    writeCsvResultHeader(outCsvFile, choices);
end

% Add more rounds to make a whole number of blocks
nBlock = ceil(nRound / roundsPerBlock);
nRound = roundsPerBlock * nBlock;

for b = 1:nBlock
    block = randperm(nF * roundsPerBlock);
    for f = 1:nF
        oldInds = mod(block, nF) == mod(f, nF);
        newInds = f : nF : nF * roundsPerBlock;
        block(oldInds) = newInds;
    end
    
    for fi = 1:length(block)
        f = mod(block(fi) - 1, nF) + 1;
        i = (b-1)*roundsPerBlock + floor((block(fi)-1) / nF) + 1;

        % fprintf('Right answer: %s\n', rightAnswers{f});  % Cheat
        
        bn = basename(files{f}, 0);
        [outMixFile,num(f),outFile] = nextAvailableFile(outMixDir, ...
            '%s_bps%s_snr%+d_%03d', {bn, subjectName, snr_db}, num(f), '.wav');
        outMatFile = strrep(outMixFile, '.wav', '.mat');
        outCleanFile = fullfile(outCleanDir, sprintf('%s_bpsInf_snr%+d_000.wav', bn, snr_db));
        
        % Create bubble mixture
        [mix fs clean] = mixBubbleNoise(paths{f}, targetFs, useHoles, perStimBps(f), snr, dur_s, normalize, noiseShape);
        
        wavWriteBetter(mix, fs, outMixFile);
        if ~exist('outCleanFile', 'file')
            wavWriteBetter(clean, fs, outCleanFile);
        end
        
        [totCorrect totIncorrect response wasRight] = playFileGetAndSaveChoice(outMixFile, rightAnswers{f}, ...
            outCsvFile, subjectName, choices, choiceNums, allowRepeats, ...
            giveFeedback, totCorrect, totIncorrect, (b-1)*nF*roundsPerBlock+fi, nRound*nF, vertical);
        
        % Update perStimPast and perStimBps
        perStimPast(f,i) = wasRight;
        if globalBps
            % Adjust all BPS's the same, should keep them in sync assuming
            % they start in sync
            perStimBps = updateBps(perStimBps, perStimPast(f,1:i), targetCorrectness, nF);
        else
            % Adjust only the current BPS
            perStimBps(f) = updateBps(perStimBps(f), perStimPast(f,1:i), targetCorrectness, 1);
        end
            
        save(outMatFile, 'response', 'wasRight', 'bn', 'cleanWavDir', 'subjectName', ...
            'choices', 'f', 'i', 'rightAnswers', 'giveFeedback', 'allowRepeats', ...
            'perStimPast', 'perStimBps', 'initialBps', 'dur_s', 'snr_db', ...
            'noiseShape', 'normalize', 'globalBps');
    end
end
fprintf('Avg %g%% correct\n', 100*totCorrect / (totCorrect + totIncorrect));
nLast = min(size(perStimPast,2), 10);
lastPctCorr = sum(perStimPast(:,end-nLast+1:end), 2);
fprintf('Final bubbles-per-second levels and recent answers correct:\n')
for f = 1:length(files)
    fprintf('  %s\t\t%g bps\t\t%d/%d correct\n', files{f}, perStimBps(f), lastPctCorr(f), nLast);
end

showAdaptiveInfo(outMixDir)


function newBps = updateBps(oldBps, history, targetCorrectness, slowDown)
% Use a weighted up-down procedure to adjust BPS

posMultInc = 1.02 .^ (1/slowDown);
negMultInc = posMultInc ^ (targetCorrectness / (1 - targetCorrectness));
if history(end)
    newBps = oldBps / posMultInc;
    %fprintf('Correct, updating bps from %g by %g to %g\n', oldBps, posMultInc, newBps);
else
    newBps = oldBps * negMultInc;
    %fprintf('Incorrect, updating bps from %g by %g to %g\n', oldBps, negMultInc, newBps);
end
