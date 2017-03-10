function analyzeAmiExp(overwrite, pattern)

% Analysis for AMI experiment

% % Generate AMI stimuli like this:
% file = '/home/data/bubbles/ami/orig/AMI_IB4010_H00_FIE038_0022314_0022648.wav';
% transcript = 'AND YOU PICK UP ON THINGS THAT YOU DID NOT REALLY NOTICE THE FIRST TIME AROUND';
% mixBubbleNoiseAmi(file, '/home/data/bubbles/ami/notice', 'notice', 10, 40, -10, transcript);

% Then on the command line run
% amiResultsForBubbles.py '/home/data/kaldi/ami/exp/ihm/tri3/decode_bubbles__bps40_snr-10_ami_fsh.o3g.kn.pr1-7/ascore_7/bubbles_bps40_snr-10.ctm.filt.sgml' 'tri3_7' '/home/data/kaldi/ami/csv'

if ~exist('overwrite', 'var') || isempty(overwrite), overwrite = 0; end
if ~exist('pattern', 'var') || isempty(pattern), pattern = '.*'; end

csvDir = '/home/data/kaldi/ami/csv/';
resultDir = '/home/data/kaldi/ami/results/';

csvFiles = findFiles(csvDir, [pattern '.*.csv']);
for f = 1:length(csvFiles)
    resultFile = convertCsvFileToResult(resultDir, csvFiles{f});
    fprintf('%d: %s\n', f, resultFile);
    if exist(resultFile, 'file') && ~overwrite
        fprintf('\b <--- Skipping\n');
        continue;
    end
    loadProcessedAsrData(fullfile(csvDir, csvFiles{f}), resultFile);
end

analysisDir = '/home/data/bubblesFeat/ami/notice';
mixDir = '/home/data/bubbles/ami/notice/mixes';

[~,resultFiles] = findFiles(resultDir, pattern);

pattern = 'bps\d.*.wav';
noiseShape = '/home/data/bubbles/ami/orig/AMI_IB4010_H00_FIE038_0022314_0022648.wav';
pcaDims = [100 1000];  % 100 dimensions from 1000 files
usePcaDims = 40;
trimFrames = 0;
%overwrite = 1;
hop_s = 0.016;
maxFreq_hz = 10000;

for f = 1:length(resultFiles)
    fprintf('%d: %s\n', f, resultFiles{f});
    mainBubbleAnalysis(mixDir, resultFiles{f}, analysisDir, pattern, noiseShape, pcaDims, usePcaDims, trimFrames, hop_s, overwrite, 0, maxFreq_hz)
end


function resultFile = convertCsvFileToResult(resultDir, csvFile)
[d f e] = fileparts(csvFile);
resultFile = fullfile(resultDir, [d '_' f '.mat']);
