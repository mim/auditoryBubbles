function analyzeTimbre2Exps()

csvPatterns = {'(mim|tal).*.csv', '.*.csv', 'mim.*.csv', 'shc.*.csv', 'tal.*.csv'};
resNames = {'s13', 'combined', 's1', 's2', 's3'};

resDir = 'D:\Box Sync\musicBubblesLyons\timbre\results';
mixDir = 'D:\mixes\instruments\windC4E4\bps25';
verbose = 1;
ignoreStimulusDir = 1;
posThresh = 0.51;
negThresh = 0.49;

% Extract features from mixtures
baseFeatDir = 'C:\Temp\data\timbre\windC4E4';
pattern = 'bps.*.wav';
noiseShape = 3;        
pcaDims = [100 1000];  
usePcaDims = 40;
trimFrames = 15;
overwrite = 0;
hop_s = 0.016;
setLength_s = 0;
maxFreq = 5000;

for c = 1:length(csvPatterns)
    [~,inCsvFiles] = findFiles(resDir, csvPatterns{c});
    resultFile = fullfile(resDir, sprintf('res_%s.mat', resNames{c}));
    processListeningData(inCsvFiles, resultFile, verbose, ignoreStimulusDir, posThresh, negThresh);
    mainBubbleAnalysis(mixDir, resultFile, baseFeatDir, pattern, noiseShape, pcaDims, usePcaDims, trimFrames, hop_s, overwrite, setLength_s, maxFreq)
end


% Plot some stimuli and their bubble patterns
exampleFiles = {
    'D:\mixes\instruments\nonWind\bps20\Vibraphone_bps20_snr-37_000.wav'
    'D:\mixes\instruments\nonWind\bps20\Vibraphone_bps20_snr-37_001.wav'
    'D:\mixes\instruments\nonWind\bps20\Vibraphone_bps20_snr-37_002.wav'
    'D:\mixes\instruments\nonWind\bps20\Vibraphone_bps20_snr-37_003.wav'
    'D:\mixes\instruments\nonWind\bps20\Vibraphone_bps20_snr-37_004.wav'
    'D:\mixes\instruments\nonWind\bps20\Vibraphone_bps20_snr-37_005.wav'
    'D:\mixes\instruments\nonWind\bps20\Vibraphone_bps20_snr-37_006.wav'
    'D:\mixes\instruments\nonWind\bps20\Vibraphone_bps20_snr-37_007.wav'
    'D:\mixes\instruments\nonWind\bps20\Vibraphone_bps20_snr-37_008.wav'
    'D:\mixes\instruments\nonWind\bps20\Vibraphone_bps20_snr-37_009.wav'
    };
cleanFiles = repmat({'D:\mixes\instruments\nonWind\bpsInf\Vibraphone_bpsInf_snr-37_000.wav'}, size(exampleFiles));

prt('ToFile', 1, 'StartAt', 0, ...
    'Width', 3, 'Height', 3, 'NumberPlots', 0, ...
    'TargetDir', fullfile(baseFeatDir, 'examplePlots'), ...
    'SaveTicks', 1, 'Resolution', 200)
specCmap = easymap('bcyr', 255);
specCax = [-100 5];
for i = 1:length(exampleFiles)
    [clean fs nfft] = loadSpecgramBubbleFeats(cleanFiles{i}, setLength_s);
    [mix   fs nfft] = loadSpecgramBubbleFeats(exampleFiles{i}, setLength_s);
    clean = clean(:,trimFrames+1:end-trimFrames);
    mix   = mix(:,trimFrames+1:end-trimFrames);
    
    prtSpectrogram(db(mix), [basename(exampleFiles{i},0) '_mix'], fs, hop_s, specCmap, specCax, [1 1 1], maxFreq)
    prtSpectrogram(db(mix - clean), [basename(exampleFiles{i},0) '_noise'], fs, hop_s, specCmap, specCax, [1 1 1], maxFreq)
end
