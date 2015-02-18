function playAdaptiveListening(cleanWavDir, outDir, subjectName, nRound, initialBps, dur_s, snr_db, noiseShape, normalize, allowRepeats, giveFeedback)

% Play adaptive listening test, save mixes and results
%
% playAdaptiveListening(cleanWavDir, outDir, subjectName, nRound, initialBps, dur_s, snr_db, noiseShape, normalize, allowRepeats, giveFeedback)
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

if ~exist('allowRepeats', 'var') || isempty(allowRepeats), allowRepeats = 0; end
if ~exist('giveFeedback', 'var') || isempty(giveFeedback), giveFeedback = 0; end

targetFs = -1;
useHoles = true;
snr = 10^(snr_db/20);

outMixDir = fullfile(outDir, 'mix');
outCleanDir = fullfile(outDir, 'clean');
outCsvFile = fullfile(outDir, [subjectName '.csv']);

[files,paths] = findFiles(cleanWavDir, '.*.wav');
nF = length(files);

rightAnswers = listMap(@figureOutRightAnswerFromFileName, files);
choices = unique(rightAnswers)';
if length(choices) ~= 6
    % warning('Using %d choices instead of 6', length(choices))
end
choiceNums = 1:length(choices);
totCorrect = 0; totIncorrect = 0;
targetCorrectness = 0.5 * (1 + 1 / length(choices));

%perStimBps = listMap(@(x) initialBps, cell(size(files)));  % Initialize cell array of vectors with initialBps
perStimBps = initialBps * ones(size(files));
perStimPast = [];

if ~exist(outCsvFile, 'file')
    writeCsvResultHeader(outCsvFile, choices);
end

num = zeros(size(files));
for i = 1:nRound
    block = randperm(nF);
    for f = block
        % fprintf('Right answer: %s\n', rightAnswers{f});  % Cheat
        
        bn = basename(files{f}, 0);
        [outMixFile,num(f),outFile] = nextAvailableFile(outMixDir, ...
            '%s_%s_snr%+d_%03d', {bn, subjectName, snr_db}, num(f), '.wav');
        outMatFile = strrep(outMixFile, '.wav', '.mat');
        outCleanFile = fullfile(outCleanDir, sprintf('%s_snr%+d.wav', bn, snr_db));
        
        % Create bubble mixture
        [mix fs clean] = mixBubbleNoise(paths{f}, targetFs, useHoles, perStimBps(f), snr, dur_s, normalize, noiseShape);
        
        wavWriteBetter(mix, fs, outMixFile);
        if ~exist('outCleanFile', 'file')
            wavWriteBetter(clean, fs, outCleanFile);
        end
        
        [totCorrect totIncorrect response wasRight] = playFileGetAndSaveChoice(outMixFile, rightAnswers{f}, ...
            outCsvFile, subjectName, choices, choiceNums, allowRepeats, ...
            giveFeedback, totCorrect, totIncorrect, (nRound-1)*nF+i, nRound*nF);
        
        % Update perStimPast and perStimBps
        perStimPast(f,i) = wasRight;
        perStimBps(f) = updateBps(perStimBps(f), perStimPast(f,1:i), targetCorrectness);
        
        save(outMatFile, 'response', 'wasRight', 'bn', 'cleanWavDir', 'subjectName', ...
            'choices', 'f', 'i', 'rightAnswers', 'giveFeedback', 'allowRepeats', ...
            'perStimPast', 'perStimBps', 'initialBps', 'dur_s', 'snr_db', ...
            'noiseShape', 'normalize');
    end
end
fprintf('Avg %g%% correct\n', 100*totCorrect / (totCorrect + totIncorrect));
nLast = min(size(perStimPast,2), 10);
lastPctCorr = sum(perStimPast(:,end-nLast+1:end), 2);
fprintf('Final bubbles-per-second levels and recent answers correct:\n')
for f = 1:length(files)
    fprintf('  %s\t\t%g bps\t\t%d/%d correct\n', files{f}, perStimBps(f), lastPctCorr(f), nLast);
end

function newBps = updateBps(oldBps, history, targetCorrectness)
% Use a weighted up-down procedure to adjust BPS

posMultInc = 1.02;
negMultInc = posMultInc ^ (targetCorrectness / (1 - targetCorrectness));
if history(end)
    newBps = oldBps / posMultInc;
    %fprintf('Correct, updating bps from %g by %g to %g\n', oldBps, posMultInc, newBps);
else
    newBps = oldBps * negMultInc;
    %fprintf('Incorrect, updating bps from %g by %g to %g\n', oldBps, negMultInc, newBps);
end
