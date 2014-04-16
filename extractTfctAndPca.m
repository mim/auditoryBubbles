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

            clear Xte yte clean warpDist mfccDist startDist
            for c = 1:length(words),
                [~,~,Xte{c},yte{c},warped{c},~,origShape,clean{c},warpDist(c),mfccDist(c),startDist(c)] = ...
                    crossUtWarp(baseDir, pcaFiles{target}, cleanFiles{words(c)}, pcaDataFile, groupedFile, doWarp);
            end
            
            [s0 s1 sNot0 sNot1 n0 n1 sig] = computeTfctStats(yte,warped);
            clear warped
            
            ensureDirExists(outFile);
            save(outFile);
            fprintf('Wrote %s\n', outFile);
        end
    end
end

function [s0 s1 sNot0 sNot1 n0 n1 sig] = computeTfctStats(yte,warped)
n0 = zeros(size(yte));
n1 = zeros(size(yte));
s0 = zeros(length(yte), size(warped{1}, 2));
s1 = zeros(size(s0));
sNot0 = zeros(size(s0));
sNot1 = zeros(size(s0));
sig   = zeros(size(s0));

for w = 1:length(yte)
    % For TFCT
    feat0 = warped{w}(yte{w}<0,:);
    feat1 = warped{w}(yte{w}>0,:);
    s0(w,:) = sum(feat0, 1);
    s1(w,:) = sum(feat1, 1);
    sNot0(w,:) = size(feat0,1) - s0(w,:);
    sNot1(w,:) = size(feat1,1) - s1(w,:);

    % For point-biserial correlation
    n0(w) = size(feat0,1);
    n1(w) = size(feat1,1);
    sig(w,:) = std(warped{w});
end
