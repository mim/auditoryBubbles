function [mcr mcrBal nTe nTr nTeBal] = svmTrainTest(Xtr, ytr, Xte, yte, pcaDims, keepAll)

% Train SVM, test SVM
if ~exist('keepAll', 'var') || isempty(keepAll), keepAll = true; end
seed = 22;

teKeep = balanceSets(yte, keepAll, seed);
trKeep = balanceSets(ytr, true, seed+783926);
nTr = sum([(ytr(trKeep)>0) (ytr(trKeep)<0)], 1);

preds = libLinearPredFunDimRed(Xtr(trKeep,:), ytr(trKeep), Xte, pcaDims);
[acc nTe(1) nTe(2)] = classAvgAcc(yte(teKeep), preds(teKeep));
[accBal nTeBal(1) nTeBal(2)] = classAvgAcc(yte, preds);
mcr = 1 - acc;
mcrBal = 1 - accBal;

function [preds svm] = libLinearPredFunDimRed(Xtr, ytr, Xte, nDim)
Xtr = Xtr(:, 1:min(nDim,end));
Xte = Xte(:, 1:min(nDim,end));

svm = linear_train(double(ytr), sparse(double(Xtr)), '-s 2 -q');
preds = linear_predict(zeros(size(Xte,1),1), sparse(double(Xte)), svm, '-q');


function [acc nPos nNeg] = classAvgAcc(yte, preds)
% Average accuracy in positive and negative classes, baseline 0.5
pos = (yte > 0);
neg = (yte < 0);
nPos = sum(pos);
nNeg = sum(neg);
acc = 0.5 * mean(preds(pos) > 0) + 0.5 * mean(preds(neg) < 0);
