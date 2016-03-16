function processAsrDataWsj(inKaldiDir, outResultDir, lmwtFilePattern, iter, noisyIdChars)

% Like processListeningData, but for ASR results from kaldi.  Outputs a
% directory of results files (one for each word in each clean file) instead
% of just one.
%
% processAsrDataWsj(inKaldiDir, outResultDir, [lmwtFilePattern], [iter], [noisyIdChars])
%
% inKaldiDir should be the directory in exp of one asr system, e.g.,
% /data/data8/scratch/mandelm/kaldi/chime-wsj0-s5-bubbles20-avg/exp/tri3b 
% outResultDir is the base directory where results will be written. In that
% directory they will be in a subdirectory named by the model, then the
% clean file, then the language model weight, then the file named by the
% word.
%
% Each result file is an Nx6 cell array with fields: 
%   model, [blank], noisyFile, guess, isCorrect, rightAnswer

if ~exist('noisyIdChars', 'var') || isempty(noisyIdChars), noisyIdChars = 8; end
if ~exist('iter', 'var'), iter = ''; end
if ~exist('lmwtFilePattern', 'var') || isempty(lmwtFilePattern), lmwtFilePattern = '\d+.txt'; end

if isempty(iter)
    itStr = '';
else
    itStr = sprintf('_it%d', iter);
end
scoringDir = fullfile(inKaldiDir, sprintf('decode_tgpr_dev_dt_05_noisy%s/scoring/', itStr));
[~,transFiles] = findFiles(scoringDir, lmwtFilePattern);
gtFile = fullfile(scoringDir, 'test_filt.txt');
model = getModelNameFromKaldiDir(inKaldiDir);

noisyIdToFileList = fullfile(inKaldiDir, '../../data/local/data/dev_dt_05_noisy_wav.scp');
noisyIdToFileMap = makeIdToFileMap(noisyIdToFileList);

gtLines = textArray(gtFile);

for lmwti = 1:length(transFiles)
    lmwts = basename(transFiles{lmwti},0);
    fprintf('%d/%d: %s', lmwti, length(transFiles), lmwts);

    noisyLines = textArray(transFiles{lmwti});

    modelName = sprintf('%s%s_lmwt=%s',model,itStr,lmwts);
    processAsrData(noisyLines, gtLines, noisyIdToFileMap, modelName, outResultDir, @(x) noisyToCleanId(x, noisyIdChars));
    
    printStatus('\n')
end


function model = getModelNameFromKaldiDir(inKaldiDir)
% Get the name of the model from the kaldi directory we're analyzing.
% Should be the last part of the name, which is a directory, so might have
% a trailing / or not.
model = basename(inKaldiDir);
if isempty(model)
    model = basename(inKaldiDir, 0, 1);
end


function cleanId = noisyToCleanId(noisyId, noisyIdChars)
% Map a noisy file ID to a clean file ID.  A noisy file ID is a clean one
% with an extra noisyIdChars on the end that are a hash of the path to the
% noisy file.
if nargin < 2, noisyIdChars = 4; end
cleanId = noisyId(1:end-noisyIdChars);
