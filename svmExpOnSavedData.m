function [mcr data] = svmExpOnSavedData(savedFile, pcaDims, balance, nRep, nFold)
    
% Train an SVM to predict intelligibility of mixtures from time-frequency SNR
%
% [mcr data] = svmExpOnSavedData(savedFile, pcaDims, balance, nRep, nFold)

if ~exist('nFold', 'var') || isempty(nFold), nFold = 5; end
if ~exist('oldProfile', 'var') || isempty(oldProfile), oldProfile = true; end
if ~exist('balance', 'var') || isempty(balance), balance = true; end
if ~exist('pcaDims', 'var') || isempty(pcaDims), pcaDims = 50; end
if ~exist('nRep', 'var') || isempty(nRep), nRep = 1; end
nTrain = inf;

m = load(savedFile);

isRight = (m.fracRight >= 0.7) - (m.fracRight <= 0.3);
%isRight = rand(size(m.fracRight)) <= m.fracRight;

fprintf('Average label value: %g\n', mean(isRight > 0))

wrapper = @(Xtr, ytr, Xte) ...
          nestedCrossValCls(@libLinearPredFunDimRed, pcaDims, Xtr, ...
                            ytr, Xte, nFold);

for r = 1:nRep
    [mcr(r) data{r}] = crossValidate(wrapper, m.pcaFeat, isRight, ...
                                     nFold, r);
end


function [mcr data] = crossValidate(fn, X, y, nFold, seed)
% Cross validation function on nFold folds of X and y.  y should be
% a column, X should have one data point per row.  Returns mcr, the mean
% classification error rate.  fn should have the following prototype:
% [preds data] = fn(Xtr, ytr, Xte);
    
nPts = size(X,1);
if nargin < 5
    ord = randperm(nPts);
else
    ord = runWithRandomSeed(seed, @() randperm(nPts));
end
inds = cell(1, nFold);
for i = 1:nFold
    inds{i} = ord(i:nFold:end);
end
errors = 0;
for i = 1:nFold
    teInd = inds{i};
    trInd = [inds{setdiff(1:nFold, i)}];
    [preds data{i}] = fn(X(trInd,:), y(trInd), X(teInd,:));
    errors = errors + sum(y(teInd) ~= preds);
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

keep = balanceSets(ytr, inf);
Xtr = Xtr(keep,:);
ytr = ytr(keep,:);

svm = linear_train(double(ytr), sparse(Xtr), '-s 2 -q');
preds = linear_predict(zeros(size(Xte,1),1), sparse(Xte), svm, '-q');


function keep = balanceSets(isRight, nTrain)
nStart = length(isRight);
pos = find(isRight == 1);
neg = find(isRight == -1);
keep = [pos; neg];
% numPerClass = min([length(pos) length(neg) floor(nTrain/2)]);
% keep = [randomSample(pos,numPerClass); randomSample(neg,numPerClass)];
% %fprintf('Keeping %d of %d mixes (%d pos, %d neg)\n', ...
% %    length(keep), nStart, length(pos), length(neg));

function y = randomSample(x, n)
ord = randperm(length(x));
y = x(ord(1:min(end,n)));
