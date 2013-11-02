function [Xtr ytr Xte yte warped scaled origShape] = crossUtWarp(baseDir, trPcaFeatFile, cleanTeFile, pcaFile, groupedPath, doWarp)

% Load features after warping test utterance to match training utterance
%
% [Xtr ytr Xte yte warped scaled origShape] = crossUtWarp(baseDir, trPcaFeatFile, cleanTeFile, pcaFile, groupedPath, doWarp)
%
% Inputs
%   baseDir        base directory for file arguments
%   trPcaFeatFile  output of collectPcaFeatures for training utterance
%   cleanTeFile    clean utterance for test files (noisy files derived from this)
%   pcaFile        mat file containing pca matrix and normalization params
%   groupedPath    path to file with grouped listening test results
%
% Outputs
%   Xtr     training PCA features
%   ytr     training supervision values
%   Xte     testing PCA features
%   yte     testing supervision values
%   scaled  testing full features, centered and scaled before PCA

if ~exist('doWarp', 'var') || isempty(doWarp), doWarp = true; end

trPcaFeatFile = fullfile(baseDir, trPcaFeatFile);
cleanTeFile   = fullfile(baseDir, cleanTeFile);
pcaFile       = fullfile(baseDir, pcaFile);

% Load training set
tr = load(trPcaFeatFile);
Xtr = tr.pcaFeat;
ytr = tr.isRight;
keep = balanceSets(ytr, 0, 22);
ytr = ytr(keep);
Xtr = Xtr(keep,:);

% Load clean files and metadata
[teFiles teDir] = mixesForClean(cleanTeFile);
[yte,~,teFiles] = isRightFor(teFiles, groupedPath);

% Load PCA stuff
pca = load(pcaFile);
F = pca.origShape(1); T = pca.origShape(2);
weights = reshape(repmat(pca.weightVec, 1, T), 1, F*T);

% Compute warping to apply to test features
cf = tr.cleanFeat;
S1 = reshape(cf.cleanFeat, cf.origShape);
te = load(cleanTeFile);
S2 = reshape(te.cleanFeat, te.origShape);
if doWarp
    warp = alignCleanSigs(S1, S2, cf.fs, cf.nfft);
else
    warp = 1:size(S2,2);
end

% Compute PCA projections of warped features
scaled = zeros(length(teFiles), length(cf.cleanFeat));
for f = 1:length(teFiles)
    tef = load(fullfile(teDir, teFiles{f}));
    tmp = reshape(tef.features, tef.origShape);
    wTmp = reshape(tmp(:,warp), 1, []);
    warped(f,:) = wTmp;
    scaled(f,:) = bsxfun(@times, bsxfun(@minus, wTmp, pca.mu), weights ./ pca.sig);
end
Xte = scaled * pca.pcs;
origShape = tef.origShape;


function [files d] = mixesForClean(cleanFile)

[d f] = fileparts(cleanFile);
p = strrep(strrep(f, 'Inf', '15'), '000', '\d+');
files = findFiles(d, p);
