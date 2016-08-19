function analyzePreExps(toDisk, startAt)

% Analyze data from pre experiments 1 and 2

if ~exist('toDisk', 'var') || isempty(toDisk), toDisk = 0; end
if ~exist('startAt', 'var') || isempty(startAt), startAt = 0; end

analysisDir = '/home/mim/work/papers/jasa14/pics5/agreement';
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
%labelHist([grouped2{:,5}], 0.2:.1:1, 'withinUserConsistency');
labelHist([grouped2{:,5}], 0:.1:1, 'withinUserConsistency');

% Simulate same data with chance performance
sim1 = mean(rand(10,3500) < (1/6), 1);
sim2 = mean(rand(10,6500) < 0.95, 1);
labelHist([sim1 sim2], 0:.1:1, 'simulatedWithinUserPerformance')

% Simulate same data with chance performance
sim1 = mean(rand(10,3500) < (1/6), 1);
sim2 = nan * ones(1,6500);
labelHist([sim1 sim2], 0:.1:1, 'simulatedWithinUserGuessing', 0.35, 0.4)


% Inter-subject agreement of accuracies of repeated listenings
nSubj = length(files);
for j=1:nSubj
    subjAcc(:,j) = [grouped2{j:nSubj:end,5}]';
end
[~,subAxes,~,~,histAxes] = plotmatrix(lim(subjAcc - 0.05*rand(size(subjAcc)), 0, 1), 'o');
for i=1:size(subAxes,2)
    title(subAxes(1,i), sprintf('Subj %d', i), 'fontweight', 'normal'); 
end
hyl = get(histAxes, 'YLim');
newHYL = max(cat(1, hyl{:}), [], 1);
for i=1:length(histAxes)
    set(histAxes, 'YLim', newHYL);
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
%labelHist([grouped{:,5}], 0.2:0.2:1, 'acrossUserConsistency');
labelHist([grouped{:,5}], 0:0.2:1, 'acrossUserConsistency');

% Simulate same data with chance performance
sim1 = mean(rand(5,3500) < (1/6), 1);
sim2 = mean(rand(5,6500) < 0.9, 1);
labelHist([sim1 sim2], 0:.2:1, 'simulatedAcrossUserPerformance')

return


% Do bubbles processing on combined pre2 data
%mixDir = '/mnt/bighd/backup/osu/D/mixes/shannon/oneSpeaker15bps';
mixDir = '/home/data/bubbles/shannon/combined/bps15';
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
    resultFile = fullfile('/home/data/bubblesResults/shannonResults/preExps', sprintf('grouped_pre2sub%d.mat', i));
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


function labelHist(vals, bins, fileName, total, ymax)

if ~exist('total', 'var') || isempty(total), total = 1; end
if ~exist('ymax', 'var'), ymax = []; end

[h x] = hist(vals, bins);
bar(x, total * h / sum(h), 'hist')
halfBarWidth = mean(diff(x)) / 2;
xlim([min(x)-halfBarWidth max(x)+halfBarWidth]);
if ~isempty(ymax), ylim([0 ymax]), end
ylabel('Proportion of total')
xlabel('Proportion correct')
%title('Proportion correct of each mixture of 10 repeated listenings by the same subject')
prt(fileName)
