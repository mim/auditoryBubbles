function analyzeVwExp()

% Analyze data from korean sibilant experiments

analysisDir = '/home/data/bubblesFeat/vw/Xagag/';
resultDir   = '/home/data/bubblesResults/vw/Xagag/';
csvDir      = '/home/data/bubbles/vw/XagagMixes/';
baseMixDir  = '/home/data/bubbles/vw/XagagMixes/';
mixDir = baseMixDir;

subjects.vikas2 = {'vikas2'};
% subjects.vikas = {'vikas'};
subjects.mim = {'mim'};
subjects.re = {'re'};

verbose = 1;
subNames = fieldnames(subjects);
for s=1:length(subNames)
    resultFile = fullfile(resultDir, [subNames{s} '.mat']);
    fprintf('%d: %s\n', s, resultFile);
    if exist(resultFile, 'file') && 0
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
overwrite = 0;
win_s = 0.064;
trimFrames = 15 * 0.016/(win_s/4);
maxFreq_hz = 6000;

% Do bubbles processing on each subject separately
for i = 1:length(subNames)
    resultFile = fullfile(resultDir, subNames{i});
    load(resultFile);
    %listenerCorrect(:,i) = [grouped{:,5}]';
    %listenerResponse(:,i) = grouped(:,4);
    
    mainBubbleAnalysis(mixDir, resultFile, analysisDir, pattern, noiseShape, pcaDims, usePcaDims, trimFrames, win_s, overwrite, 0, maxFreq_hz)
end
%listenerResponse = cellfun(@(x) x{1}, listenerResponse, 'UniformOutput', false);

mainBubbleAnalysis(mixDir, resultFile, analysisDir, pattern, noiseShape, pcaDims, usePcaDims, trimFrames, win_s, overwrite, 0, maxFreq_hz)
