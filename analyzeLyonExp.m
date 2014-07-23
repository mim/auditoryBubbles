function analyzeLyonExp()

mixDir = 'D:\Box Sync\lyon\mixes\bps12';
hop_s = 0.016;         % this is the default hop size used in the analysis
overwrite = 0;
trimFrames = 15;
usePcaDims = 40;
pcaDims = [100 1000];  % 100 dimensions from 1000 files
verbose = 1;
noiseShape = 0;
pattern = '_bps12.*.wav';
baseFeatDir = 'C:\Temp\data\lyon';
resultDir = 'D:\Box Sync\lyon\results';

[~,inCsvFiles] = findFiles(resultDir, '.*.csv');

equivClassCell = {};
resultFile = fullfile(resultDir, 'res_combined_4way.mat');
processListeningData(inCsvFiles, resultFile, verbose, 1, equivClassCell);
mainBubbleAnalysis(mixDir, resultFile, baseFeatDir, pattern, noiseShape, pcaDims, usePcaDims, trimFrames, hop_s, overwrite);

for i = 1:length(inCsvFiles)
    resultFile = fullfile(resultDir, sprintf('res_sub%d_4way.mat',i)); 
    processListeningData(inCsvFiles{i}, resultFile, verbose, 1, equivClassCell); 
    mainBubbleAnalysis(mixDir, resultFile, baseFeatDir, pattern, noiseShape, pcaDims, usePcaDims, trimFrames, hop_s, overwrite); 
end

equivClassCell = {{'Alda','Arda'},{'Alga','Arga'}};
resultFile = fullfile(resultDir, 'res_combined_2way.mat');
processListeningData(inCsvFiles, resultFile, verbose, 1, equivClassCell);
mainBubbleAnalysis(mixDir, resultFile, baseFeatDir, pattern, noiseShape, pcaDims, usePcaDims, trimFrames, hop_s, overwrite);

for i = 1:length(inCsvFiles)
    resultFile = fullfile(resultDir, sprintf('res_sub%d_2way.mat',i)); 
    processListeningData(inCsvFiles{i}, resultFile, verbose, 1, equivClassCell); 
    mainBubbleAnalysis(mixDir, resultFile, baseFeatDir, pattern, noiseShape, pcaDims, usePcaDims, trimFrames, hop_s, overwrite); 
end
