function analyzePreExps(overwrite)

% Analyze data from pre experiments 1 and 2

if ~exist('overwrite', 'var') || isempty(overwrite), overwrite = 0; end

analysisDir = '/scratch/mim/bubbleFeat/preExps/feat/';
resultDir   = '/scratch/mim/bubbleFeat/preExps/mat/';
csvDir      = '/home/data/bubbles/csv/shannonResults/preExps/';
baseMixDir  = '/home/data/bubbles/mixes/shannon/combined';
%mixDir = fullfile(baseMixDir, 'bps15');
mixDir = baseMixDir;

subjects.p1s1 = {'pre1sub1_20140514T145911'};
subjects.p1s2 = {'pre1sub2_20140519T105044'};
subjects.p1s3 = {'pre1sub3_20140519T122932'};
subjects.p1s4 = {'pre1sub4_20140519T145118'};
subjects.p1s5 = {'pre1sub5_20140521T121917'};
subjects.p2s1 = {'pre2sub1_20140514T154526'};
subjects.p2s2 = {'pre2sub2_20140521T135632'};
subjects.p2s3 = {'pre2sub3_20140519T130129'};
subjects.p2s4 = {'pre2sub4_20140519T154918'};
subjects.p2s5 = {'pre2sub5_20140521T123449'};
subjects.p1 = {'pre1sub1_20140514T145911', ...
               'pre1sub2_20140519T105044', ...
               'pre1sub3_20140519T122932', ...
               'pre1sub4_20140519T145118', ...
               'pre1sub5_20140521T121917' };
subjects.p2 = {'pre2sub1_20140514T154526', ...
               'pre2sub2_20140521T135632', ...
               'pre2sub3_20140519T130129', ...
               'pre2sub4_20140519T154918', ...
               'pre2sub5_20140521T123449'};
subjects.all = {'pre1sub1_20140514T145911', ...
                'pre1sub2_20140519T105044', ...
                'pre1sub3_20140519T122932', ...
                'pre1sub4_20140519T145118', ...
                'pre1sub5_20140521T121917', ...
                'pre2sub1_20140514T154526', ...
                'pre2sub2_20140521T135632', ...
                'pre2sub3_20140519T130129', ...
                'pre2sub4_20140519T154918', ...
                'pre2sub5_20140521T123449'};

verbose = 1;
subNames = fieldnames(subjects);
for s=1:length(subNames)
    resultFile = fullfile(resultDir, [subNames{s} '.mat']);
    fprintf('%d: %s\n', s, resultFile);
    if exist(resultFile, 'file') && ~overwrite
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

pattern = 'bps15.*.wav';
noiseShape = 0;
pcaDims = [100 1000];  % 100 dimensions from 1000 files
usePcaDims = 40;
trimFrames = 15;
overwrite = 0;
hop_s = 0.016;
setLength_s = 2.2;
maxFreq_hz = 8000;

% Create list of result files
for i = 1:length(subNames)
    resultFiles{i} = fullfile(resultDir, subNames{i});
end

% Run many analyses in a row (one per results file)
mainBubbleAnalysis(mixDir, resultFiles, analysisDir, pattern, noiseShape, pcaDims, usePcaDims, trimFrames, hop_s, overwrite, setLength_s, maxFreq_hz)
