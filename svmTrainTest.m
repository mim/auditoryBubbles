function [mcr mcrBal nTe nTr nTeBal svm] = svmTrainTest(Xtr, ytr, Xte, yte, pcaDims, teGroup, keepAll, limNTr)

% Train SVM, test SVM
if ~exist('teGroup', 'var') || isempty(teGroup), teGroup = ones(size(yte)); end
if ~exist('keepAll', 'var') || isempty(keepAll), keepAll = true; end
if ~exist('limNTr', 'var') || isempty(limNTr), limNTr = inf; end
seed = 22;

trKeep = balanceSets(ytr, keepAll, seed+783926, limNTr);
nTr = sum([(ytr(trKeep)>0) (ytr(trKeep)<0)], 1);

[preds svm] = libLinearPredFunDimRed(Xtr(trKeep,:), ytr(trKeep), Xte, pcaDims);
groups = unique(teGroup);
mcr = []; mcrBal = []; nTe = []; nTeBal = [];
for g = 1:length(groups)
    gInds = find(teGroup == groups(g));
    teKeep = balanceSets(yte(gInds), false, seed+g);
    [acc nTe(g,1) nTe(g,2)] = classAvgAcc(yte(gInds(teKeep)), preds(gInds(teKeep)));
    [accBal nTeBal(g,1) nTeBal(g,2)] = classAvgAcc(yte(gInds), preds(gInds));
    mcr(g) = 1 - acc;
    mcrBal(g) = 1 - accBal;
end
    
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
