function collectPcaFeatures(pcaDir, featDir, groupedFile, outDir, overwrite, condition)

% Collect output of extractBubbleFeatures and match up with user results
%
% collectPcaFeatures(pcaDir, featDir, groupedFile, outDir, overwrite, condition)
%
% Saves one file of PCA reduced features for each unique clean stimulus,
% grouping together mixture files that share the same clean stimulus.
%
% Inputs:
%   pcaDir       directory containing PCA features for all files
%   featDir      directory containing pre-PCA features for all files
%   groupedFile  mat file with output of processListeningData()
%   outDir       directory to write PCA .mat file and 
%   overwrite    if 0, do not overwrite existing files
%   condition    used to group files with the same clean speech {'bubbles','remix'}

if ~exist('overwrite', 'var') || isempty(overwrite), overwrite = false; end
if ~exist('condition', 'var') || isempty(condition), condition = 'bubbles'; end

[isRight fracRight files responseCounts equivClasses] = ...
    isRightFor(findFiles(pcaDir, '\.mat$'), groupedFile);

% Group by word, load PCA features
switch condition
    case {'bubbles', 'bubble'}
        % Noise instance appends a number at the end
        word = regexprep(regexprep(files, '\d+.mat', ''), 'bps[^_/\\]*', 'bps');
    case {'remix', 'grid', 'asr', 'chime1'}
        % Noise instance prepends the file the noise came from as a directory
        word = listMap(@(x) basename(x, 0, 0), files);
    case {'wsj', 'chime2'}
        % Noise instance prepends the file the noise came from as a directory
        word = listMap(@(x) basename(x, 0, 1), files);
    otherwise
        error('Uknown condition: %s', condition)
end

[words,~,wi] = unique(word);
for w = 1:length(words)
    use = (wi == w);
    saveWordFile(words{w}, pcaDir, featDir, files(use), fracRight(use), isRight(use), ...
        responseCounts(use), equivClasses, outDir, overwrite)
end


function saveWordFile(word, inDir, featDir, files, fracRight, isRight, ...
    responseCounts, equivClasses, outDir, overwrite)

outFile = fullfile(outDir, [word '.mat']);
if exist(outFile, 'file') && ~overwrite
    return
end

noisyPath = fullfile(featDir, files{1});
noisyToCleanFn = findNoisyToCleanFn(noisyPath);
cleanFeat = load(noisyToCleanFn(noisyPath));

for f = 1:length(files)
    tmp = load(fullfile(inDir, files{f}));
    pcaFeat(f,:) = tmp.pcaFeat';
    origShape = tmp.origShape;
end

ensureDirExists(outFile)
save(outFile, 'pcaFeat', 'fracRight', 'files', 'inDir', 'isRight', ...
    'responseCounts', 'equivClasses', 'cleanFeat', 'origShape')


function cf = cleanFileName(word, pcaDir)
d = fileparts(fileparts(pcaDir(1:end-1)));
if reMatch(word, 'bps[^_/\\]*')
    fileName = [regexprep(word, 'bps[^_/\\]*', 'bpsInf') '000'];
else
    fileName = word;
end
cf = fullfile(d, 'feat', [fileName '.mat']);
