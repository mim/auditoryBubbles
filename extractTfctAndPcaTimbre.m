function extractTfctAndPcaTimbre(groupedName, overwrite)

% Extract features necessary to run lots of different experiments and
% visualizations

if ~exist('overwrite', 'var') || isempty(overwrite), overwrite = false; end
if ~exist('groupedName', 'var') || isempty(groupedName), groupedName = 'mim100'; end

outDir = fullfile('C:\Temp\data\timbre\v1', groupedName, 'expWarpCache');
baseDir = fullfile('C:\Temp\mrtFeatures\timbre\mim\trim=15,length=0');
pcaDataFile = 'pcaData_100dims_1000files.mat';
groupedFile = fullfile('D:\Box Sync\timbre\results\', sprintf('%sgrouped.mat', groupedName));

collectPcaFeatures(fullfile(baseDir, 'pca_100dims_1000files'), ...
    groupedFile, fullfile(baseDir, 'pcaFeat_100dims_1000files'), 0);

targets = 1:7;
doWarps = 0;
numDiffWords = 0;

extractTfctAndPca(outDir, baseDir, pcaDataFile, groupedFile, targets, doWarps, numDiffWords, overwrite);
