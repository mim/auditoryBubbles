function [mcr mcrBal nTe nTr nTeBal] = svmTrainTest(Xtr, ytr, Xte, yte, pcaDims, teGroup, keepAll)

% Train SVM, test SVM
if ~exist('teGroup', 'var') || isempty(teGroup), teGroup = ones(size(yte)); end
if ~exist('keepAll', 'var') || isempty(keepAll), keepAll = true; end
seed = 22;

teKeep = balanceSets(yte, false, seed);
trKeep = balanceSets(ytr, keepAll, seed+783926);
nTr = sum([(ytr(trKeep)>0) (ytr(trKeep)<0)], 1);

preds = libLinearPredFunDimRed(Xtr(trKeep,:), ytr(trKeep), Xte, pcaDims);
groups = unique(teGroup);
for g = 1:length(groups)
    gInds = find(teGroup == groups(g));
    [acc nTeT(1) nTeT(2)] = classAvgAcc(yte(intersect(gInds,teKeep)), preds(intersect(gInds,teKeep)));
    [accBal nTeBalT(1) nTeBalT(2)] = classAvgAcc(yte(gInds), preds(gInds));
    mcr(g) = 1 - acc;
    mcrBal(g) = 1 - accBal;
    if g == 1
        nTe = nTeT;
        nTeBal = nTeBalT;
    end
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
