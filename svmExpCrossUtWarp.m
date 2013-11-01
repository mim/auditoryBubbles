function mcr = svmExpCrossUtWarp(baseDir, trPcaFeatFile, cleanTeFile, pcaFile, groupedFile, pcaDims)

% Train an SVM on one utterance, test on warped other utterance

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
[yte,~,teFiles] = isRightFor(teFiles, groupedFile);

% Load PCA stuff
pca = load(pcaFile);
F = pca.origShape(1); T = pca.origShape(2);
weights = reshape(repmat(pca.weightVec, 1, T), 1, F*T);

% Compute warping to apply to test features
cf = tr.cleanFeat;
S1 = reshape(cf.cleanFeat, cf.origShape);
te = load(cleanTeFile);
S2 = reshape(te.cleanFeat, te.origShape);
warp = alignCleanSigs(S1, S2, cf.fs, cf.nfft);

% Compute PCA projections of warped features
scaled = zeros(length(teFiles), length(cf.cleanFeat));
for f = 1:length(teFiles)
    tef = load(fullfile(teDir, teFiles{f}));
    tmp = reshape(tef.features, tef.origShape);
    warped = reshape(tmp(:,warp), 1, []);
    scaled(f,:) = bsxfun(@times, bsxfun(@minus, warped, pca.mu), weights ./ pca.sig);
end
Xte = scaled * pca.pcs;

% Train SVM, test SVM
preds = libLinearPredFunDimRed(Xtr, ytr, Xte, pcaDims);
mcr = 1 - classAvgAcc(yte, preds);




function [files d] = mixesForClean(cleanFile)

[d f] = fileparts(cleanFile);
p = strrep(strrep(f, 'Inf', '15'), '000', '\d+');
files = findFiles(d, p);


function [preds svm] = libLinearPredFunDimRed(Xtr, ytr, Xte, nDim)
Xtr = Xtr(:, 1:min(nDim,end));
Xte = Xte(:, 1:min(nDim,end));

svm = linear_train(double(ytr), sparse(double(Xtr)), '-s 2 -q');
preds = linear_predict(zeros(size(Xte,1),1), sparse(double(Xte)), svm, '-q');


function acc = classAvgAcc(yte, preds)
% Average accuracy in positive and negative classes, baseline 0.5
pos = (yte > 0);
neg = (yte < 0);
acc = 0.5 * mean(preds(pos) > 0) + 0.5 * mean(preds(neg) < 0);
