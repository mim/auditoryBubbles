function analyzeGridExpHuman()

% Just the human part

overwrite = 2;

verbose = 1;
ignoreStimulusDir = 1;

[~,inCsvFiles] = findFiles('/home/data/bubbles/grid/id16mix/', '(Felix|RENEE|jcdVer1|mim).csv')
resultFileBase = '/home/data/bubblesResults/gridAdaptAll';
processListeningDataGrid(inCsvFiles, resultFileBase, verbose, ignoreStimulusDir, [], [], [], 1);

[~,inCsvFiles] = findFiles('/home/data/bubbles/grid/id16mix/', '(Felix|RENEE|jcdVer1).csv')
resultFileBase = '/home/data/bubblesResults/gridAdaptNonMim';
processListeningDataGrid(inCsvFiles, resultFileBase, verbose, ignoreStimulusDir);

[~,inCsvFiles] = findFiles('/home/data/bubbles/grid/id16mix/', 'mim.csv')
resultFileBase = '/home/data/bubblesResults/gridAdaptMim';
processListeningDataGrid(inCsvFiles, resultFileBase, verbose, ignoreStimulusDir);

[~,resultFiles] = findFiles('/home/data/bubblesResults/', 'gridAdapt.*.mat')

baseFeatDir = '/home/data/bubblesFeat/gridAllAdapt';
mixDir = '/home/data/bubbles/grid/id16mix/bpsAll';
pattern = 'bps.*.wav';
pcaDims = [100 1000];  % 100 dimensions from 1000 files
usePcaDims = 40;
trimFrames = 0;
hop_s = 0.016;         % this is the default hop size used in the analysis
setLength_s = 0;
maxFreq_hz = 10000;
noiseRef = '/home/data/bubbles/grid/id16orig.wav';

for i=1:length(resultFiles), 
    mainBubbleAnalysis(mixDir, resultFiles{i}, baseFeatDir, pattern, noiseRef, pcaDims, usePcaDims, trimFrames, hop_s, overwrite, setLength_s, maxFreq_hz); 
end
