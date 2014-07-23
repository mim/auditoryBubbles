function analyzeTimbreExps()

resDir = 'D:\Box Sync\timbre\results';
mixDir = 'D:\mixes\instruments\nonWind\bps20';
[~,inCsvFiles] = findFiles(resDir, 'nonWind20.*.csv');
resultFile = fullfile(resDir, 'res_combined.mat');
verbose = 1;
ignoreStimulusDir = 1;
processListeningData(inCsvFiles, resultFile, verbose, ignoreStimulusDir);

% Extract features from mixtures
baseFeatDir = 'C:\Temp\data\timbre';
pattern = 'bps20.*.wav';
noiseShape = 3;        
pcaDims = [100 1000];  
usePcaDims = 40;
trimFrames = 15;
overwrite = 0;
hop_s = 0.016;         

mainBubbleAnalysis(mixDir, resultFile, baseFeatDir, pattern, noiseShape, pcaDims, usePcaDims, trimFrames, hop_s, overwrite)

for c = 1:length(inCsvFiles)
    resultFile = fullfile(resDir, sprintf('res_sub%d.mat', c));
    processListeningData(inCsvFiles{c}, resultFile, verbose, ignoreStimulusDir);
    mainBubbleAnalysis(mixDir, resultFile, baseFeatDir, pattern, noiseShape, pcaDims, usePcaDims, trimFrames, hop_s, overwrite)
end
