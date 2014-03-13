function [mcr data] = svmXVal(pcaFeat, isRight, pcaDims, nRep, nFold)
    
% Run nested cross-validation experiment with SVM to select PCA dims
%
% [mcr data] = svmXVal(pcaFeat, isRight, pcaDims, nRep, nFold)

if ~exist('nFold', 'var') || isempty(nFold), nFold = 5; end
if ~exist('pcaDims', 'var') || isempty(pcaDims), pcaDims = 50; end
if ~exist('nRep', 'var') || isempty(nRep), nRep = 1; end

%fprintf('Average label value: %g\n', sum(isRight > 0) ./ sum(isRight~= 0))

% for p = 1:length(pcaDims)
%     for r = 1:nRep
%         mcr(p,r) = crossValidate(@(Xtr, ytr, Xte) ...
%                                  libLinearPredFunDimRed(Xtr, ytr, Xte, pcaDims(p)), ...
%                                  pcaFeat, isRight, nFold, r);
%     end
% end
% data = [];
% return

wrapper = @(Xtr, ytr, Xte) ...
          nestedCrossValCls(@libLinearPredFunDimRed, pcaDims, Xtr, ...
                            ytr, Xte, nFold);

for r = 1:nRep
    [mcr(r) data{r}] = crossValidate(wrapper, pcaFeat, isRight, ...
                                     nFold, r);
end


function [mcr data] = crossValidate(fn, X, y, nFold, seed)
% Cross validation function on nFold folds of X and y.  y should be
% a column, X should have one data point per row.  Returns mcr, the mean
% classification error rate.  fn should have the following prototype:
% [preds data] = fn(Xtr, ytr, Xte);

ord = balanceSets(y, true, seed);
inds = cell(1, nFold);
for i = 1:nFold
    inds{i} = ord(i:nFold:end);
end

nPts = 0; errors = 0;
for i = 1:nFold
    teInd = inds{i};
    trInd = cat(1, inds{setdiff(1:nFold, i)});
    
    teKeep = balanceSets(y(teInd), false, seed);
    teInd = teInd(teKeep);
    trKeep = balanceSets(y(trInd), false, seed+783926);
    trInd = trInd(trKeep);
    
    tData.nTr = sum([(y(trInd)>0) (y(trInd)<0)],1);
    tData.nTe = sum([(y(teInd)>0) (y(teInd)<0)],1);
    tData.unbalanced = sum([(y>0) (y<0)], 1);
    
    [preds tData.fromFn] = fn(X(trInd,:), y(trInd), X(teInd,:));
    errors = errors + sum(y(teInd) ~= preds);
    nPts = nPts + length(preds);
    
    data(i) = tData;
end
mcr = errors / nPts;

function [preds data] = nestedCrossValCls(fn, paramVec, Xtr, ytr, Xte, nFold)
% Run a cross-validation inside of another cross-validation.  fn
% should have the following prototype:
% [preds data] = fn(Xtr, ytr, Xte, param)
% The value of param will range over paramVec and the one with the
% best performance will be used to make the final predictions.
    
mcr = inf*ones(size(paramVec));
for i = 1:length(paramVec)
    mcr(i) = crossValidate(@(Xtr2, ytr2, Xte2) ...
                           fn(Xtr2, ytr2, Xte2, paramVec(i)), ...
                           Xtr, ytr, nFold, i);
end
[~,ind] = min(mcr);
data = paramVec(ind);
preds = fn(Xtr, ytr, Xte, paramVec(ind));

function [preds svm] = libLinearPredFunDimRed(Xtr, ytr, Xte, nDim)
Xtr = Xtr(:, 1:min(nDim,end));
Xte = Xte(:, 1:min(nDim,end));

svm = linear_train(double(ytr), sparse(double(Xtr)), '-s 2 -q');
preds = linear_predict(zeros(size(Xte,1),1), sparse(double(Xte)), svm, '-q');

