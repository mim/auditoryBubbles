function analyzeLyonExp()

oneAnalysis({}, '4way')
oneAnalysis({{'Alda','Arda'},{'Alga','Arga'}}, 'dg')
oneAnalysis({{'Alda','Alga'},{'Arda','Arga'}}, 'lr')


function oneAnalysis(equivClassCell, name)
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

resultFile = fullfile(resultDir, ['res_combined_' name '.mat']);
processListeningData(inCsvFiles, resultFile, verbose, 1, equivClassCell);
mainBubbleAnalysis(mixDir, resultFile, baseFeatDir, pattern, noiseShape, pcaDims, usePcaDims, trimFrames, hop_s, overwrite);

for i = 1:length(inCsvFiles)
    subjId = regexprep(basename(inCsvFiles{i}), '_\d+T\d+.csv', '');
    fprintf('\nSubject %s\n', subjId);
    resultFile = fullfile(resultDir, sprintf('res_sub%s_%s.mat', subjId, name)); 
    processListeningData(inCsvFiles{i}, resultFile, verbose, 1, equivClassCell); 
    mainBubbleAnalysis(mixDir, resultFile, baseFeatDir, pattern, noiseShape, pcaDims, usePcaDims, trimFrames, hop_s, overwrite); 
end
