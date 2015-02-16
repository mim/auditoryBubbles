function plotsBubbleExamples(toDisk, startAt)

% Collect data from expWarpExtensive, format into tables for interspeech paper

if ~exist('toDisk', 'var') || isempty(toDisk), toDisk = false; end
if ~exist('startAt', 'var') || isempty(startAt), startAt = 0; end

setLength_s = 0;
specCmap = easymap('bcyr', 255);
specCax = [-99 5];
hop_s = 0.016;
maxFreq_hz = 8000;
outDir = 'Z:\data\plots\bubblesExamples';

prt('ToFile', toDisk, 'StartAt', startAt, ...
    'Width', 3, 'Height', 3, 'NumberPlots', 0, ...
    'TargetDir', outDir, ...
    'SaveTicks', 1, 'Resolution', 200)

mixFiles = {
    'D:\mixes\shannon\oneSpeaker15bps\ada_w3_09_07_bps15_snr-35_001.wav'
    'D:\mixes\shannon\oneSpeaker15bps\ada_w3_09_07_bps15_snr-35_002.wav'
    'D:\mixes\shannon\oneSpeaker15bps\ada_w3_09_07_bps15_snr-35_003.wav'
    'D:\mixes\shannon\oneSpeaker15bps\ada_w3_09_07_bps15_snr-35_004.wav'
    'D:\mixes\shannon\oneSpeaker15bps\ada_w3_09_07_bps15_snr-35_005.wav'
    'D:\mixes\shannon\oneSpeaker15bps\ada_w3_09_07_bps15_snr-35_006.wav'
    };
cleanFiles = {
    'D:\mixes\shannon\oneSpeaker15bps\ada_w3_09_07_bpsInf_snr-35_000.wav'    
    'D:\mixes\shannon\oneSpeaker15bps\ada_w3_09_07_bpsInf_snr-35_000.wav'    
    'D:\mixes\shannon\oneSpeaker15bps\ada_w3_09_07_bpsInf_snr-35_000.wav'    
    'D:\mixes\shannon\oneSpeaker15bps\ada_w3_09_07_bpsInf_snr-35_000.wav'    
    'D:\mixes\shannon\oneSpeaker15bps\ada_w3_09_07_bpsInf_snr-35_000.wav'    
    'D:\mixes\shannon\oneSpeaker15bps\ada_w3_09_07_bpsInf_snr-35_000.wav'    
    };

for f = 1:length(mixFiles)
    [mix fs nfft] = loadSpecgramBubbleFeats(mixFiles{f}, setLength_s);
    [clean fs nfft] = loadSpecgramBubbleFeats(cleanFiles{f}, setLength_s);
    
    baseFileName = basename(mixFiles{f}, 0);
    prtSpectrogram(db(mix),         [baseFileName '_mix'],   fs, hop_s, specCmap, specCax, [1 1 1], maxFreq_hz);
    prtSpectrogram(db(clean),       [baseFileName '_clean'], fs, hop_s, specCmap, specCax, [1 1 1], maxFreq_hz);
    prtSpectrogram(db(mix - clean), [baseFileName '_noise'], fs, hop_s, specCmap, specCax, [1 1 1], maxFreq_hz);

    if toDisk
        copyfile(mixFiles{f}, fullfile(outDir, [baseFileName '_mix.wav']))
        copyfile(cleanFiles{f}, fullfile(outDir, [baseFileName '_clean.wav']))
    end
end
