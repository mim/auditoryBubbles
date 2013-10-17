function mcr = svmExpAcrossUts(trMatFile, teMatFile, pcaDims)

% Train an SVM on one utterance (PCA feat) and test on another (PCA feat)

seed = 22;

[Xtr ytr] = loadSetMat(trMatFile, false, seed);
[Xte yte] = loadSetMat(teMatFile, true, seed+950176119);
preds = libLinearPredFunDimRed(Xtr, ytr, Xte, pcaDims);
%mcr = mean(yte ~= preds);
mcr = 1 - classAvgAcc(yte, preds);


function [X y] = loadSetMat(matFile, keepAll, seed)

m = load(matFile);
X = m.pcaFeat;
y = (m.fracRight >= 0.4) - (m.fracRight <= 0.3);

keep = balanceSets(y, keepAll, seed);
y = y(keep);
X = X(keep,:);


function [preds svm] = libLinearPredFunDimRed(Xtr, ytr, Xte, nDim)
Xtr = Xtr(:, 1:min(nDim,end));
Xte = Xte(:, 1:min(nDim,end));

svm = linear_train(double(ytr), sparse(Xtr), '-s 2 -q');
preds = linear_predict(zeros(size(Xte,1),1), sparse(Xte), svm, '-q');


function acc = classAvgAcc(yte, preds)
% Average accuracy in positive and negative classes, baseline 0.5
pos = (yte > 0);
neg = (yte < 0);
acc = 0.5 * mean(preds(pos) > 0) + 0.5 * mean(preds(neg) < 0);
