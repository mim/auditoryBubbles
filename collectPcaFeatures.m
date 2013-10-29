function collectPcaFeatures(pcaDir, groupedFile, outDir, overwrite)

% Collect output of extractBubbleFeatures and match up with user results

if ~exist('overwrite', 'var') || isempty(overwrite), overwrite = false; end

[isRight,fracRight,files] = isRightFor(findFiles(pcaDir, '\d+.mat'), groupedFile);

% Group by word, load PCA features
word  = regexprep(files, '\d+.mat', '');
[words,~,wi] = unique(word);
for w = 1:length(words)
    use = (wi == w);
    saveWordFile(words{w}, pcaDir, files(use), fracRight(use), isRight(use), outDir, overwrite)
end


function saveWordFile(word, inDir, files, fracRight, isRight, outDir, overwrite)

outFile = fullfile(outDir, [word '.mat']);
if exist(outFile, 'file') && ~overwrite
    return
end

cleanFeat = load(cleanFileName(word, inDir));

for f = 1:length(files)
    tmp = load(fullfile(inDir, files{f}));
    pcaFeat(f,:) = tmp.pcaFeat';
end

ensureDirExists(outFile)
save(outFile, 'pcaFeat', 'fracRight', 'files', 'inDir', 'isRight', 'cleanFeat')


function cf = cleanFileName(word, pcaDir)
d = fileparts(pcaDir(1:end-1));
fileName = [regexprep(word, 'bps\d+', 'bpsInf') '000.mat'];
cf = fullfile(d, 'feat', fileName);
