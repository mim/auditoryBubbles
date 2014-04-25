function extractTfctAndPcaShannon(overwrite, expNum, trimDir)

% Extract features necessary to run lots of different experiments and
% visualizations

if ~exist('trimDir', 'var') || isempty(trimDir), trimDir = 'trim=30,length=2.2'; end
if ~exist('expNum', 'var') || isempty(expNum), expNum = 12; end
if ~exist('overwrite', 'var') || isempty(overwrite), overwrite = false; end

expDir  = sprintf('exp%d', expNum); 
outDir      = fullfile('C:\Temp\data\jasaTfctAndPcaPbc', expDir, trimDir);
baseDir     = fullfile('C:\Temp\mrtFeatures\shannonJasa', expDir, trimDir);
pcaDataFile = 'pcaData_100dims_1000files.mat';
groupedFile = fullfile('D:\Box Sync\data\mrt\shannonResults', sprintf('groupedExp%dTmp.mat', expNum));

targets = [5:6:36 2:6:36];
doWarps = [1 0];
numDiffWords = 3;

extractTfctAndPca(outDir, baseDir, pcaDataFile, groupedFile, targets, doWarps, numDiffWords, overwrite);
