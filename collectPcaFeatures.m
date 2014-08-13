function collectPcaFeatures(pcaDir, groupedFile, outDir, overwrite)

% Collect output of extractBubbleFeatures and match up with user results
%
% collectPcaFeatures(pcaDir, groupedFile, outDir, overwrite)
%
% Saves one file of PCA reduced features for each unique clean stimulus,
% grouping together mixture files that share the same clean stimulus.
%
% Inputs:
%   pcaDir       directory containing PCA features for all files
%   groupedFile  mat file with output of processListeningData()
%   outDir       directory to write PCA .mat file and 
%   overwrite    if 0, do not overwrite existing files

if ~exist('overwrite', 'var') || isempty(overwrite), overwrite = false; end

[isRight fracRight files responseCounts equivClasses] = ...
    isRightFor(findFiles(pcaDir, '\d+.mat'), groupedFile);

% Group by word, load PCA features
word  = regexprep(files, '\d+.mat', '');
[words,~,wi] = unique(word);
for w = 1:length(words)
    use = (wi == w);
    saveWordFile(words{w}, pcaDir, files(use), fracRight(use), isRight(use), ...
        responseCounts(use), equivClasses, outDir, overwrite)
end


function saveWordFile(word, inDir, files, fracRight, isRight, ...
    responseCounts, equivClasses, outDir, overwrite)

outFile = fullfile(outDir, [word '.mat']);
if exist(outFile, 'file') && ~overwrite
    return
end

cleanFeat = load(cleanFileName(word, inDir));

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
fileName = [regexprep(word, 'bps\d+', 'bpsInf') '000.mat'];
cf = fullfile(d, 'feat', fileName);
