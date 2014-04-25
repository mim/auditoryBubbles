function extractTfctAndPca(outDir, baseDir, pcaDataFile, groupedFile, targets, doWarps, numDiffWords, overwrite)

% Generic function to extract features necessary to run lots of different
% experiments and visualizations. Write a wrapper for it for the particular
% directories you need.
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
if ~exist('numDiffWords', 'var') || isempty(numDiffWords), numDiffWords = 3; end

seed = 22;

cleanFiles  = findFiles(baseDir, 'bpsInf');
pcaFiles    = findFiles(baseDir, 'snr-\d+_.mat');

%for grouping = 1
for grouping = 0
    for doWarp = doWarps
        for target = targets
            outFile = fullfile(outDir, sprintf('grouping=%d', grouping), ...
                sprintf('doWarp=%d', doWarp), sprintf('target=%d',target), ...
                'tfctAndPca.mat');
            if exist(outFile, 'file') && ~overwrite
                fprintf('Skipping %s\n', outFile)
                continue
            end
            
            [sameWord wordNames speakers uts diffWord] = sameWordFor(target, pcaFiles, grouping);
            diffWordInds = runWithRandomSeed(seed, @() randperm(length(diffWord)));
            words = [sameWord diffWord(diffWordInds(1:numDiffWords))];

            clear Xte yte clean warpDist mfccDist startDist s0 s1 sNot0 sNot1 n0 n1 sig
            for c = 1:length(words),
                [~,~,Xte{c},yte{c},warped,~,origShape,clean{c},warpDist(c),mfccDist(c),startDist(c)] = ...
                    crossUtWarp(baseDir, pcaFiles{target}, cleanFiles{words(c)}, pcaDataFile, groupedFile, doWarp);
                
                [s0(c,:) s1(c,:) sNot0(c,:) sNot1(c,:) n0(c) n1(c) sig(c,:)] = computeTfctStats(yte{c}, warped);
            end            
            clear warped
            
            ensureDirExists(outFile);
            save(outFile);
            fprintf('Wrote %s\n', outFile);
        end
    end
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
