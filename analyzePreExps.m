function analyzePreExps()

% Analyze data from pre experiments 1 and 2

analysisDir = 'C:\Temp\data\preExp\pre2';

% Intra-subject agreement
[~,files] = findFiles('D:\Box Sync\data\mrt\shannonResults\preExps\', 'pre1.*.mat');
grouped={}; 
for i = 1:length(files), 
    g = load(files{i}); 
    grouped = [grouped; g.grouped]; 
end
for i=1:size(grouped,1), 
    grouped{i,7} = [grouped{i,1}{1} '_' regexprep(grouped{i,3}, '_\d+.wav', '')]; 
end
grouped2 = groupBy(grouped, 7, @(x) mean([x{:}]), 5);
labelHist([grouped2{:,5}], 0.2:.1:1, 'withinUserConsistency', analysisDir);

% Inter-subject agreement
resultFile = 'D:\Box Sync\data\mrt\shannonResults\preExps\grouped_pre2.mat';
verbose = 1;
[~,inCsvFiles] = findFiles('D:\Box Sync\data\mrt\shannonResults\preExps\', 'pre2.*.csv');
processListeningData(inCsvFiles, resultFile, verbose);
load(resultFile)
labelHist([grouped{:,5}], 0.2:0.2:1, 'acrossUserConsistency', analysisDir);

% Do bubbles processing on combined pre2 data
mixDir = 'D:\mixes\shannon\oneSpeaker15bps';
pattern = 'bps15.*.wav';
noiseShape = 0;
pcaDims = [100 1000];  % 100 dimensions from 1000 files
usePcaDims = 40;
trimFrames = 15;
overwrite = 0;
hop_s = 0.016;
mainBubbleAnalysis(mixDir, resultFile, analysisDir, pattern, noiseShape, pcaDims, usePcaDims, trimFrames, hop_s, overwrite)

% Do bubbles processing on each pre2 data separately
for i = 1:length(inCsvFiles)
    resultFile = fullfile('D:\Box Sync\data\mrt\shannonResults\preExps', sprintf('grouped_pre2sub%d.mat', i));
    processListeningData(inCsvFiles{i}, resultFile, verbose);
    mainBubbleAnalysis(mixDir, resultFile, analysisDir, pattern, noiseShape, pcaDims, usePcaDims, trimFrames, hop_s, overwrite)
end

% Do bubbles processing on pre2 data merged with previous data
% TODO: do this


function labelHist(vals, bins, fileName, dir, toFile)
if nargin < 5, toFile = 1; end

[h x] = hist(vals, bins);
bar(x, h / sum(h), 'hist')
ylabel('Proportion of mixtures')
xlabel('Proportion of presentations in which a mixture was correctly identified')
%title('Proportion correct of each mixture of 10 repeated listenings by the same subject')
if toFile
    print('-dpng', fullfile(dir, fileName))
end
