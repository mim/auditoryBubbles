function analyzeKoreanExp()

% Analyze data from korean sibilant experiments

analysisDir = '/home/data/bubblesFeat/koreanSAdapt2/';
resultDir   = '/home/data/bubblesResults/koreanSAdapt/';
csvDir      = '/home/data/bubbles/koreanS/mix/jiyoung/';
baseMixDir  = '/home/data/bubbles/koreanS/mix/jiyoung/';
mixDir = baseMixDir;

subjects.aaron = {'Aaron'};
subjects.alix  = {'Alix', 'Alix2'};
subjects.jaekoo = {'Jaekoo'};
subjects.jiyoung = {'Jiyoung', 'Jiyoung2'};
subjects.nicole = {'Nicole'};
subjects.scotty = {'Scotty'};
subjects.vanessa = {'Vanessa'};
subjects.yeonju = {'Yeonju'};
subjects.mim = {'mim', 'mimg'};
subjects.native = {'Jaekoo','Jiyoung', 'Jiyoung2', 'Yeonju'};
subjects.nonnative = {'Aaron', 'Alix', 'Alix2', 'Nicole', 'Scotty', 'Vanessa', 'mim', 'mimg'};
% subjects.all = {'Jaekoo','Jiyoung', 'Jiyoung2', 'Yeonju', ...
%     'Aaron', 'Alix', 'Alix2', 'Nicole', 'Scotty', 'Vanessa', 'mim', 'mimg'};

verbose = 1;
subNames = fieldnames(subjects);
for s=1:length(subNames)
    resultFile = fullfile(resultDir, [subNames{s} '.mat']);
    fprintf('%d: %s\n', s, resultFile);
    if exist(resultFile, 'file')
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
noiseShape = 0;
pcaDims = [100 1000];  % 100 dimensions from 1000 files
usePcaDims = 40;
trimFrames = 15;
overwrite = 0;
hop_s = 0.016;
maxFreq_hz = 10000;

% Do bubbles processing on each subject separately
for i = 1:length(subNames)
    resultFile = fullfile(resultDir, subNames{i});
    load(resultFile);
    listenerCorrect(:,i) = [grouped{:,5}]';
    listenerResponse(:,i) = grouped(:,4);
    
    mainBubbleAnalysis(mixDir, resultFile, analysisDir, pattern, noiseShape, pcaDims, usePcaDims, trimFrames, hop_s, overwrite, 0, maxFreq_hz)
end
listenerResponse = cellfun(@(x) x{1}, listenerResponse, 'UniformOutput', false);

mainBubbleAnalysis(mixDir, resultFile, analysisDir, pattern, noiseShape, pcaDims, usePcaDims, trimFrames, hop_s, overwrite, 0, maxFreq_hz)
