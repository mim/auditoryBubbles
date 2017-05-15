function analyzeVwExp(overwrite, useFdr)

% Analyze data from hindi v-w experiments

if ~exist('overwrite', 'var') || isempty(overwrite), overwrite = 0; end
if ~exist('useFdr', 'var') || isempty(useFdr), useFdr = false; end

analysisDir = '/home/data/bubblesFeat/vw/Xagag/';
resultDir   = '/home/data/bubblesResults/vw/Xagag/';
csvDir      = '/home/data/bubbles/vw/XagagMixes/';
baseMixDir  = '/home/data/bubbles/vw/XagagMixes/';
mixDir = baseMixDir;

% subjects.hindi = {'re', 'vikas2'};
% subjects.vikas2 = {'vikas2'};
% % subjects.vikas = {'vikas'};
subjects.mim = {'mim', 'mim2', 'mim3', 'mim4'};
% subjects.re = {'re'};

verbose = 1;
subNames = fieldnames(subjects);
for s=1:length(subNames)
    resultFile = fullfile(resultDir, [subNames{s} '.mat']);
    fprintf('%d: %s\n', s, resultFile);
    if exist(resultFile, 'file') && (overwrite <= 0)
        fprintf('\b <--- Skipping\n');
        continue;
    end
    
    csvFiles = subjects.(subNames{s});
    inCsvFiles = {};
    for n=1:length(csvFiles)
        inCsvFiles{n} = fullfile(csvDir, [csvFiles{n} '.csv']);
    end
    processListeningData(inCsvFiles, resultFile, verbose);
end

pattern = 'bps.*.wav';
noiseShape = '/home/data/bubbles/vw/speechRef.wav';
pcaDims = [100 1000];  % 100 dimensions from 1000 files
usePcaDims = 40;
win_s = 0.064;
trimFrames = 15 * 0.016/(win_s/4);
maxFreq_hz = 6000;

% Do bubbles processing on each subject separately
for i = 1:length(subNames)
    resultFile = fullfile(resultDir, subNames{i});
    load(resultFile);
    %listenerCorrect(:,i) = [grouped{:,5}]';
    %listenerResponse(:,i) = grouped(:,4);
    
    mainBubbleAnalysis(mixDir, resultFile, analysisDir, pattern, noiseShape, pcaDims, usePcaDims, trimFrames, win_s, overwrite, 0, maxFreq_hz, '', useFdr)
end
%listenerResponse = cellfun(@(x) x{1}, listenerResponse, 'UniformOutput', false);

mainBubbleAnalysis(mixDir, resultFile, analysisDir, pattern, noiseShape, pcaDims, usePcaDims, trimFrames, win_s, overwrite, 0, maxFreq_hz, '', useFdr)
