function playActiveBubbleDir(cleanWavDir, outDir, subjectName, nRound, dur_s, snr_db, noiseShape, maxFreq_hz, allowRepeats, giveFeedback)

% Play interactive bubble game, save mixes and results

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
    fprintf('Right answer: %s\n', rightAnswers{f});  % Cheat
    
    bn = basename(files{f}, 0);
    [outMixFile,num(f),outFile] = nextAvailableFile(outMixDir, ...
        '%s_snr%+d_%03d', {bn, snr_db}, num(f), '.wav');
    outMatFile = strrep(outMixFile, '.wav', '.mat');
    outCleanFile = fullfile(outCleanDir, outFile);

    [mix clean fs bubbleF_erb bubbleT_s] = activeBubbleWav(paths{f}, dur_s, snr_db, noiseShape, maxFreq_hz);

    wavWriteBetter(mix, fs, outMixFile);
    wavWriteBetter(clean, fs, outCleanFile);
    
    [correct incorrect response] = playFileGetAndSaveChoice(outMixFile, rightAnswers{f}, ...
        outCsvFile, subjectName, choices, choiceNums, allowRepeats, ...
        giveFeedback, correct, incorrect, i, nRound);    
    
    save(outMatFile, 'response', 'bn', 'cleanWavDir', 'bubbleF_erb', 'bubbleT_s', ...
        'choices', 'f', 'rightAnswers');
end
fprintf('Avg %g%% correct\n', 100*correct / (correct + incorrect));
