function extractTfctAndPcaTimbre(overwrite)

% Extract features necessary to run lots of different experiments and
% visualizations

if ~exist('overwrite', 'var') || isempty(overwrite), overwrite = false; end

outDir = 'C:\Temp\data\timbre\v1\expWarpCache';
baseDir = fullfile('C:\Temp\mrtFeatures\timbre\mim\trim=15,length=0');
pcaDataFile = 'pcaData_100dims_1000files.mat';
groupedFile = 'D:\Box Sync\timbre\results\mim100grouped.mat';

collectPcaFeatures(fullfile(baseDir, 'pca_100dims_1000files'), ...
    groupedFile, fullfile(baseDir, 'pcaFeat_100dims_1000files'), 0);

targets = 1:7;
doWarps = 0;
numDiffWords = 0;

extractTfctAndPca(outDir, baseDir, pcaDataFile, groupedFile, targets, doWarps, numDiffWords, overwrite);
