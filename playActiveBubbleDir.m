function playActiveBubbleDir(cleanWavDir, outDir, subjectName, nRound, dur_s, snr_db, noiseShape, maxFreq_hz, allowRepeats, giveFeedback, playAll, bubbleSpeech)

% Play interactive bubble game, save mixes and results
%
% playActiveBubbleDir(cleanWavDir, outDir, subjectName, nRound, dur_s, snr_db, noiseShape, maxFreq_hz, allowRepeats, giveFeedback, playAll, bubbleSpeech)
%
% For each clean file, the player clicks on various points on a spectrogram
% to reveal their neighborhoods (create a bubble) in a loud noise field.
% The player then guesses which word it was that they heard.  Guessing with
% fewer bubbles is more desirable.  Resulting mixtures and clean files are
% saved in outDir/mix and outDir/clean, respectively, with results saved in
% outDir/subjectName.csv and extra information saved in a mat file with the
% same name as the mixture.  Resulting csv file can then be analyzed by
% processListeningData.  Cumulative results for each subject name are saved
% in the same file, so using the same name with the same output directory
% will add to that file.
%
% Input arguments:
%   cleanWavDir    Directory containing clean wav files to be used
%   outDir         Base directory of output wavs and data
%   subjectName    Identifier for player, cumulative results saved in corresponding csv file
%   nRound         Number of rounds to play (clean file repetitions)
%   dur_s          Minimum duration to enforce for each file by zero padding
%   snr_db         Signal-to-noise ratio to use in mixtures (usuall around -25)
%   noiseShape     Identified of noise as used by speechProfile.m
%   maxFreq_hz     Maximum frequency in hz to show in interactive visualization
%   allowRepeats   If 1, listener can play final file multiple times
%   giveFeedback   If 1, tell listener whether they got each guess correct
%   playAll        If 1, play mixture after each click for training purposes
%   bubbleSpeech   If 1, bubbles set speech to silence with no noise, else set noise to silence

if ~exist('maxFreq_hz', 'var') || isempty(maxFreq_hz), maxFreq_hz = 4000; end
if ~exist('allowRepeats', 'var') || isempty(allowRepeats), allowRepeats = 0; end
if ~exist('giveFeedback', 'var') || isempty(giveFeedback), giveFeedback = 0; end
if ~exist('playAll', 'var') || isempty(playAll), playAll = false; end
if ~exist('bubbleSpeech', 'var') || isempty(bubbleSpeech), bubbleSpeech = false; end

outMixDir = fullfile(outDir, 'mix');
outCleanDir = fullfile(outDir, 'clean');
outCsvFile = fullfile(outDir, [subjectName '.csv']);

[files,paths] = findFiles(cleanWavDir, '.*.wav');

rightAnswers = listMap(@figureOutRightAnswerFromFileName, files);
choices = unique(rightAnswers)';
if length(choices) ~= 6
    warning('Using %d choices instead of 6', length(choices))
end
choiceNums = 1:length(choices);
correct = 0; incorrect = 0;

if ~exist(outCsvFile, 'file')
    writeCsvResultHeader(outCsvFile, choices);
end

fprintf('Left-click to reveal areas of the word\nRight-click to hear it and guess\n\n')

num = zeros(size(files));
for i = 1:nRound
    f = randi(length(files));
    % fprintf('Right answer: %s\n', rightAnswers{f});  % Cheat
    
    bn = basename(files{f}, 0);
    [outMixFile,num(f),outFile] = nextAvailableFile(outMixDir, ...
        '%s_snr%+d_%03d', {bn, snr_db}, num(f), '.wav');
    outMatFile = strrep(outMixFile, '.wav', '.mat');
    outCleanFile = fullfile(outCleanDir, outFile);

    [mix clean fs bubbleF_erb bubbleT_s] = activeBubbleWav(paths{f}, dur_s, snr_db, playAll, noiseShape, maxFreq_hz, bubbleSpeech);

    wavWriteBetter(mix, fs, outMixFile);
    wavWriteBetter(clean, fs, outCleanFile);
    
    [correct incorrect response] = playFileGetAndSaveChoice(outMixFile, rightAnswers{f}, ...
        outCsvFile, subjectName, choices, choiceNums, allowRepeats, ...
        giveFeedback, correct, incorrect, i, nRound);    
    
    save(outMatFile, 'response', 'bn', 'cleanWavDir', 'bubbleF_erb', 'bubbleT_s', ...
        'choices', 'f', 'rightAnswers', 'playAll', 'giveFeedback', 'allowRepeats');
end
fprintf('Avg %g%% correct\n', 100*correct / (correct + incorrect));
