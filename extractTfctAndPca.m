function extractTfctAndPca(overwrite, expNum, trimDir)

% Extract features necessary to run lots of different experiments and
% visualizations

if ~exist('trimDir', 'var') || isempty(trimDir), trimDir = 'trim=30,length=2.2'; end
if ~exist('expNum', 'var') || isempty(expNum), expNum = 12; end
if ~exist('overwrite', 'var') || isempty(overwrite), overwrite = false; end

seed = 22;
numDiffWords = 3;

expDir  = sprintf('exp%d', expNum); 
outDir      = fullfile('C:\Temp\data\jasaTfctAndPcaPbc', expDir, trimDir);
baseDir     = fullfile('C:\Temp\mrtFeatures\shannonJasa', expDir, trimDir);
pcaDataFile = 'pcaData_100dims_1000files.mat';
groupedFile = fullfile('D:\Box Sync\data\mrt\shannonResults', sprintf('groupedExp%dTmp.mat', expNum));
cleanFiles  = findFiles(baseDir, 'bpsInf');
pcaFiles    = findFiles(baseDir, 'snr-35_.mat');

%for grouping = 1
for grouping = 0
    for doWarp = [1 0]
        for target = [5:6:length(pcaFiles) 2:6:length(pcaFiles)]
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
