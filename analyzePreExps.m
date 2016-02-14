function analyzePreExps()

% Analyze data from pre experiments 1 and 2

analysisDir = '/home/mim/work/papers/jasa14/pics4/agreement';
toDisk = 0;
startAt = 0;
prt('ToFile', toDisk, 'StartAt', startAt, ...
    'Width', 3.5, 'Height', 3.5, 'NumberPlots', 0, ...
    'TargetDir', analysisDir, ...
    'SaveTicks', 1, 'Resolution', 200)

% Intra-subject agreement
[~,files] = findFiles('/home/data/bubblesResults/shannonResults/preExps/', 'pre1.*.mat');
grouped={}; 
for i = 1:length(files), 
    g = load(files{i}); 
    grouped = [grouped; g.grouped]; 
end
for i=1:size(grouped,1), 
    grouped{i,7} = [grouped{i,1}{1} '_' regexprep(grouped{i,3}, '_\d+.wav', '')]; 
end
grouped2 = groupBy(grouped, 7, @(x) mean([x{:}]), 5);
labelHist([grouped2{:,5}], 0.2:.1:1, 'withinUserConsistency');

% Inter-subject agreement of accuracies of repeated listenings
nSubj = length(files);
for j=1:nSubj
    subjAcc(:,j) = [grouped2{j:nSubj:end,5}]';
end
[~,subAxes] = plotmatrix(lim(subjAcc - 0.05*rand(size(subjAcc)), 0, 1), 'o');
for i=1:size(subAxes,2)
    title(subAxes(1,i), sprintf('Subj %d', i), 'fontweight', 'normal'); 
end
for i=1:size(subAxes,1)
    set(subAxes(i,end), 'YAxisLocation', 'right')
    ylabel(subAxes(i,end), sprintf('Subj %d', i), 'fontweight', 'normal'); 
end
xlabel('Proportion correct')
ylabel('Proportion correct')
prt('acrossUserAccCorr', 'Width', 3, 'Height', 3)

% Inter-subject agreement
resultFile = '/home/data/bubblesResults/shannonResults/preExps/grouped_pre2.mat';
verbose = 1;
[~,inCsvFiles] = findFiles('/home/data/bubblesResults/shannonResults/preExps/', 'pre2.*.csv');
%processListeningData(inCsvFiles, resultFile, verbose);
load(resultFile)
labelHist([grouped{:,5}], 0.2:0.2:1, 'acrossUserConsistency');

return


% Do bubbles processing on combined pre2 data
mixDir = 'D:\mixes\shannon\oneSpeaker15bps';
pattern = 'bps15.*.wav';
noiseShape = 0;
pcaDims = [100 1000];  % 100 dimensions from 1000 files
usePcaDims = 40;
trimFrames = 15;
overwrite = 0;
hop_s = 0.016;
maxFreq_hz = 8000;
mainBubbleAnalysis(mixDir, resultFile, analysisDir, pattern, noiseShape, pcaDims, usePcaDims, trimFrames, hop_s, overwrite, 0, maxFreq_hz)

% Do bubbles processing on each pre2 data separately
for i = 1:length(inCsvFiles)
    resultFile = fullfile('D:\Box Sync\data\mrt\shannonResults\preExps', sprintf('grouped_pre2sub%d.mat', i));
    processListeningData(inCsvFiles{i}, resultFile, verbose);
    load(resultFile);
    listenerCorrect(:,i) = [grouped{:,5}]';
    listenerResponse(:,i) = grouped(:,4);
    mainBubbleAnalysis(mixDir, resultFile, analysisDir, pattern, noiseShape, pcaDims, usePcaDims, trimFrames, hop_s, overwrite, 0, maxFreq_hz)
end
listenerResponse = cellfun(@(x) x{1}, listenerResponse, 'UniformOutput', false);

% Inter-subject Cohen's kappa
kr = zeros(size(listenerResponse,2));
kc = zeros(size(listenerResponse,2));
for i = 1:size(listenerResponse,2)
    for j = i+1:size(listenerResponse,2)
        kr(i,j) = kappa(confusionmat(listenerResponse(:,i), listenerResponse(:,j)));
        kc(i,j) = kappa(confusionmat(listenerCorrect(:,i), listenerCorrect(:,j)));
    end
end
disp('Kappa for listener correctness')
kc

disp('Kappa for listener responses')
kr


% Do bubbles processing on pre2 data merged with previous data
% TODO: do this


function labelHist(vals, bins, fileName)

[h x] = hist(vals, bins);
bar(x, h / sum(h), 'hist')
halfBarWidth = mean(diff(x)) / 2;
xlim([min(x)-halfBarWidth max(x)+halfBarWidth]);
ylabel('Proportion of total')
xlabel('Proportion correct')
%title('Proportion correct of each mixture of 10 repeated listenings by the same subject')
prt(fileName)
