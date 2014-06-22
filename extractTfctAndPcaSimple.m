function extractTfctAndPcaSimple(outDir, featDir, groupedFeatDir, pcaDataFile, groupedFile, overwrite)

% Extract features necessary to run several experiments and visualizations
%
% extractTfctAndPcaSimple(outDir, featDir, groupedFeatDir, pcaDataFile, groupedFile, overwrite)
%
% Inputs
%   outDir       base directory for output directory tree
%   featDir      base directory containing full (non-PCA) features
%   groupedFeatDir  base directory containing full PCA features grouped by
%                   original word
%   pcaDataFile  .mat file with pca info, e.g. 'pcaData_100dims_1000files.mat'
%   groupedFile  .mat file containing grouped results from listening test
%   overwrite    if 1, overwrite existing output files

if ~exist('overwrite', 'var') || isempty(overwrite), overwrite = 0; end

cleanFiles  = findFiles(featDir, 'bpsInf');
pcaFiles    = findFiles(groupedFeatDir, 'snr-\d+_.mat');

for target = 1:length(pcaFiles)
    outFile = fullfile(outDir, sprintf('target=%s',basename(pcaFiles{target},0,0)), ...
        'tfctAndPca.mat');
    if exist(outFile, 'file') && ~overwrite
        fprintf('Skipping %s\n', outFile)
        continue
    end
    
    [~,~,Xte,yte,warped,~,origShape,clean,warpDist,mfccDist,startDist] = ...
        crossUtWarp(fullfile(groupedFeatDir, pcaFiles{target}), ...
        fullfile(featDir, cleanFiles{target}), pcaDataFile, groupedFile, 0);
    
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
