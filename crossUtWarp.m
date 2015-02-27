function [Xtr ytr Xte yte ytem mNames warped scaled origShape warpedClean warpDist mfccDist startDist] = ...
    crossUtWarp(trPcaFeatFile, cleanTeFile, pcaFile, groupedPath, doWarp)

% Load features after warping test utterance to match training utterance
%
% [Xtr ytr Xte yte warped scaled origShape warpedClean warpDist] = crossUtWarp(trPcaFeatFile, cleanTeFile, pcaFile, groupedPath, doWarp)
%
% Inputs
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
%   warped  testing features only warped, not centered, scaled, or PCA'd
%   scaled  testing full features, centered and scaled before PCA
%   origShape  2-vector of the original shape of the spectrograms
%   warpedClean  clean spectrogram of test signal warped to align with train
%   warpDist     average number of frames a frame in S2 is moved
%   mfccDist     average L2 distance in MFCC space between S1 and warped S2
%   startDist    average L2 distance in MFCC space between S1 and unwarped S2

if ~exist('doWarp', 'var') || isempty(doWarp), doWarp = true; end

% Load training set
tr = load(trPcaFeatFile);
Xtr = tr.pcaFeat;
ytr = tr.isRight;
keep = balanceSets(ytr, 0, 22);
ytr = ytr(keep);
Xtr = Xtr(keep,:);

% Load clean files and metadata
[teFiles teDir] = mixesForClean(cleanTeFile);
[yte,~,teFiles,ytem,mNames] = isRightFor(teFiles, groupedPath);

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
    [warp mfccDist startDist] = alignCleanSigs(S1, S2, cf.fs, cf.nfft);
else
    warp = 1:size(S2,2);
    mfccDist = 0;
    startDist = 0;
end
warpedClean = S2(:,warp);
warpDist = mean(abs(warp - (1:size(S2,2))));

% Compute PCA projections of warped features
warped = zeros(length(teFiles), length(cf.cleanFeat));
scaled = zeros(length(teFiles), length(cf.cleanFeat));
for f = 1:length(teFiles)
    tef = load(fullfile(teDir, teFiles{f}));
    tmp = reshape(tef.features, tef.origShape);
    wTmp = reshape(tmp(:,warp), 1, []);
    warped(f,:) = wTmp;
    scaled(f,:) = bsxfun(@times, bsxfun(@minus, wTmp, pca.mu), weights ./ pca.sig);
end
Xte = scaled * pca.pcs;
origShape = cf.origShape;


function [files d] = mixesForClean(cleanFile)

[d f] = fileparts(cleanFile);
p = strrep(strrep(f, 'bpsInf', 'bps[^_/\\]+'), '000', '\d+');
files = findFiles(d, p);
