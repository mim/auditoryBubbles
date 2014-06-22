function extractTfctAndPcaSimple(outDir, baseDir, pcaDataFile, groupedFile, overwrite)

% Extract features necessary to run several experiments and visualizations
%
% extractTfctAndPca(outDir, baseDir, pcaDataFile, groupedFile, overwrite)
%
% Inputs
%   outDir       base directory for output directory tree
%   baseDir      base directory for input directory tree
%   pcaDataFile  .mat file with pca info, e.g. 'pcaData_100dims_1000files.mat'
%   groupedFile  .mat file containing grouped results from listening test
%   overwrite    if 1, overwrite existing output files

if ~exist('overwrite', 'var') || isempty(overwrite), overwrite = 0; end

cleanFiles  = findFiles(baseDir, 'bpsInf');
pcaFiles    = findFiles(baseDir, 'snr-\d+_.mat');

for target = 1:length(pcaFiles)
    outFile = fullfile(outDir, sprintf('target=%d',target), ...
        'tfctAndPca.mat');
    if exist(outFile, 'file') && ~overwrite
        fprintf('Skipping %s\n', outFile)
        continue
    end
    
    [~,~,Xte,yte,warped,~,origShape,clean,warpDist,mfccDist,startDist] = ...
        crossUtWarp(baseDir, pcaFiles{target}, cleanFiles{target}, pcaDataFile, groupedFile, 0);
    
    [s0 s1 sNot0 sNot1 n0 n1 sig] = computeTfctStats(yte, warped);
    clear warped
    
    ensureDirExists(outFile);
    save(outFile);
    fprintf('Wrote %s\n', outFile);
end

function [s0 s1 sNot0 sNot1 n0 n1 sig] = computeTfctStats(yte,warped)
% For TFCT
feat0 = warped(yte<0,:);
feat1 = warped(yte>0,:);
s0 = sum(feat0, 1);
s1 = sum(feat1, 1);
sNot0 = size(feat0,1) - s0;
sNot1 = size(feat1,1) - s1;

% For point-biserial correlation
n0 = size(feat0,1);
n1 = size(feat1,1);
sig = std(warped,[],1);
