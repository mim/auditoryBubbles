function analyzeInterspeechExp()

mixDir = 'D:\mixes\shannon\combined\bps15';
[~,inCsvFiles] = findFiles('D:\Box Sync\data\mrt\shannonResults\orig', '.*.csv');

resultFile = 'D:\Box Sync\data\mrt\shannonResults\orig\resultsNew.mat';
verbose = 1;
ignoreStimulusDir = 1;
processListeningData(inCsvFiles, resultFile, verbose, ignoreStimulusDir);

baseFeatDir = 'C:\Temp\data\origExp';
pattern = 'bps15.*.wav';
noiseShape = 0;        % whatever you use for your noise shape
pcaDims = [100 1000];  % 100 dimensions from 1000 files
usePcaDims = 70;
trimFrames = 30;
overwrite = 0;
hop_s = 0.016;         % this is the default hop size used in the analysis
setLength_s = 2.2;
maxFreq_hz = 8000;
featDir = mainBubbleAnalysis(mixDir, resultFile, baseFeatDir, pattern, noiseShape, pcaDims, usePcaDims, trimFrames, hop_s, overwrite, setLength_s, maxFreq_hz);

snrDir = fullfile(fileparts(featDir), 'snr');
extractSnr(mixDir, snrDir, overwrite);
