function playActiveBubbleDir(cleanWavDir, outMixDir, outCleanDir, nRound, dur_s, snr_db, noiseShape, maxFreq_hz)

% Play interactive bubble game, save mixes and results

[files,paths] = findFiles(cleanWavDir, '.*.wav');
choices = {};

fprintf('Left-click to reveal areas of the word\nRight-click to hear it and guess\n\n')

for i = 1:nRound
    f = randi(length(files))
    [mix clean fs response bubbleF_erb bubbleT_s] = activeBubbleWav(paths{f}, dur_s, snr_db, choices, noiseShape, maxFreq_hz);
    
    bn = basename(files{f}, 0);
    outMixFile = fullfile(outMixDir, sprintf('%s_%i.wav', bn, i));
    outMatFile = fullfile(outMixDir, sprintf('%s_%i.mat', bn, i));
    outCleanFile = fullfile(outCleanDir, sprintf('%s_%i.wav', bn, i));
    wavWriteBetter(mix, fs, outMixFile);
    wavWriteBetter(clean, fs, outCleanFile);
    save(outMatFile, 'response', 'bn', 'cleanWavDir', 'bubbleF_erb', 'bubbleT_s', 'choices');
end
