function mcr = svmImportance(word, path, groupedFile, pcaDim, nRep, nTrain, oldProfile, balance, thresh, nAvg, nFold)

% Train an SVM to predict intelligibility of mixtures from time-frequency SNR
%
% [map features] = svmImportance(word, path, mturkOutFiles, nFold, nTrain, nAvg, thresh)
%
% word is a string specifying which word to use.  path is the directory
% where the clean speech and mixes live.  Clean speech should be in
% [path]/[word].wav, mixes should be in [path]/[word][num].wav .
% mturkOutFiles is a cell array of CSV files containing the output from
% MTurk experiments.  nFold is the number of cross-validation folds to use.
% nTrain is the number of mixes to use in training the classifier, they
% will be randomly selected from those available in the training folds.
% nAvg is the number of answers to each mixture to average over to get the
% training data.  thresh is the minimum fraction correct to count as
% "intelligible".

if ~exist('thresh', 'var') || isempty(thresh), thresh = [0.3 0.7]; end
if ~exist('nFold', 'var') || isempty(nFold), nFold = 5; end
if ~exist('nTrain', 'var') || isempty(nTrain), nTrain = inf; end
if ~exist('oldProfile', 'var') || isempty(oldProfile), oldProfile = true; end
if ~exist('balance', 'var') || isempty(balance), balance = true; end
if ~exist('nAvg', 'var') || isempty(nAvg), nAvg = inf; end
if ~exist('pcaDim', 'var') || isempty(pcaDim), pcaDim = 50; end
if ~exist('nRep', 'var') || isempty(nRep), nRep = 1; end

if numel(thresh) == 1, thresh = [thresh thresh]; end
thresh = sort(thresh);

% Should contain a variable "grouped"
load(groupedFile);
ansFile = strrep(grouped(:,3), '\', filesep);

mixPaths = {}; fracRight = []; isRight = [];
for i = 1:length(ansFile)
    if ~reMatch(ansFile{i}, [word '\d+\.wav']), continue, end
    mixPath = fullfile(path, ansFile{i});
    cls = (grouped{i,5} >= thresh(2)) - (grouped{i,5} <= thresh(1));
    if exist(mixPath, 'file') && cls
        mixPaths{end+1} = mixPath;
        fracRight(end+1) = grouped{i,5};
        isRight(end+1) = cls;
    end
end
mixPaths = mixPaths(:); fracRight = fracRight(:); isRight = isRight(:);

if balance
    % Balance positives and negatives
    keep = balanceSets(isRight, nTrain);
    mixPaths  = mixPaths(keep);
    fracRight = fracRight(keep);
    isRight   = isRight(keep);
end

cleanFile = fullfile(path, [word '.wav']);
[clean fs nFft] = loadSpecgram(cleanFile);

%features = zeros(length(mixPaths), 2*numel(clean));
for i = 1:length(mixPaths)
    mix = loadSpecgram(mixPaths{i});
    [features(i,:) origShape weights cleanFeat] = bubbleFeatures(clean, mix, fs, nFft, oldProfile);
end

fprintf('Average label value: %g %g\n', mean(fracRight), mean(isRight > 0))

%figure(1);
plotMeanStuff(cleanFeat, features, isRight > 0, origShape);

[pcs,pcaFeat] = princomp(bsxfun(@times, weights, zscore(features)), 'econ');
pause(1)
%figure(2);

%xvalArgs = {'leaveout', 1};
xvalArgs = {'kfold', nFold};

length(pcaDim)
nRep
mcr = NaN * ones(length(pcaDim), nRep);
for p = 1:length(pcaDim)
    fprintf('.')

    pcaFeatTrunc = pcaFeat(:,1:min(end,pcaDim(p)));
    pcsTrunc = pcs(:,1:min(end,pcaDim(p)));
    
    try
        [~,pcaVec] = svmPredFun(pcaFeatTrunc, isRight, pcaFeatTrunc);
        %[~,pcaVec] = libLinearPredFun(pcaFeatTrunc, nominal(isRight), pcaFeatTrunc);
        subplots(reshape(-pcaVec * pcsTrunc', origShape)); drawnow
    catch e
        fprintf('Oops')
    end

    for rep = 1:nRep
        try
            %mcr(p, rep) = lassoXVal(features, fracRight, origShape)
            %mcr(p, rep) = linear_train(double(isRight), sparse(features), '-s 2 -v 41 -q');
            %mcr(p, rep) = crossval('mcr', features, isRight, 'Predfun', @(Xtr, ytr, Xte) libLinearPredFun(Xtr, ytr, Xte), xvalArgs{:})
            %mcr(p, rep) = crossval('mcr', features, isRight, 'Predfun', @(Xtr, ytr, Xte) svmPredFun(Xtr, ytr, Xte), xvalArgs{:})
            mcr(p, rep) = crossval('mcr', pcaFeatTrunc, isRight, 'Predfun', @(Xtr, ytr, Xte) svmPredFun(Xtr, ytr, Xte), xvalArgs{:});
            %mcr(p, rep) = crossval('mcr', pcaFeatTrunc, isRight, 'Predfun', @(Xtr, ytr, Xte) libLinearPredFun(Xtr, ytr, Xte), xvalArgs{:});
            %mcr(p, rep) = crossval('mcr', features, isRight>0, 'Predfun', @ldaPredFun, xvalArgs{:})
        catch e
            fprintf('Oops')
        end
    end
end
fprintf('\n')

function [preds rep] = svmPredFun(Xtr, ytr, Xte)
options = statset('MaxIter', 1e5);
svm   = svmtrain(Xtr, ytr, 'options', options);
preds = svmclassify(svm, Xte);
rep = (svm.Alpha' * svm.SupportVectors) ./ svm.ScaleData.scaleFactor - svm.ScaleData.shift;

function [preds rep] = libLinearPredFun(Xtr, ytr, Xte)
svm = linear_train(double(ytr), sparse(Xtr), '-s 0 -q -c 1');
cls = linear_predict(zeros(size(Xte,1),1), sparse(Xte), svm, '-q');
n = nominal(getlevels(ytr), getlabels(ytr))';
preds = n(cls);
%sign = (2-svm.Label(1))*2-1;
sign = 3 - 2*svm.Label(1);
rep = sign * svm.w;

function preds = ldaPredFun(Xtr, ytr, Xte)
preds = classify(Xte, Xtr, ytr, 'diaglinear');

function [mcr rep] = lassoXVal(X, y)
[b fitinfo] = lasso(X, y, 'CV', 3, 'NumLambda', 9, 'Alpha', 0.1);
lam = fitinfo.Index1SE; % find index of suggested lambda
rep = b(:,lam);
mcr = fitinfo.MSE(lam);  % TODO: this is not right


function [spec fs nfft] = loadSpecgram(fileName)
% Load a spectrogram of a wav file
win_s = 0.064;

[x fs] = wavReadBetter(fileName);
nfft = round(win_s * fs);
hop = round(nfft/4);
spec = stft(x', nfft, nfft, hop);


function plotMeanStuff(cleanFeat, features, isRight, shape)

feat1 = features( isRight,:);
feat0 = features(~isRight,:);
mn1 = mean(feat1);
mn0 = mean(feat0);
mn = mean(features);
sd01 = std([bsxfun(@minus, feat1, mn1); bsxfun(@minus, feat0, mn0)]);
dPrime = (mn1 - mn0) ./ sd01;
[h p isHigh] = tfCrossTab(sum(1-feat0), sum(1-feat1), sum(feat0), sum(feat1));

%subplots(listMap(@(x) reshape(x, shape), {mn1, dPrime, mn0, cleanFeat}), [], [], @meanStuffCaxis)
%subplots(listMap(@(x) reshape(x, shape), {mn1./mn, dPrime, mn0./mn, mn}), [], [], @meanStuffCaxis)
%subplots(listMap(@(x) reshape(x, shape), {sum(feat1)./sum(features), h, exp(-p/.05), cleanFeat}), [], [], @meanStuffCaxis)
%subplots(listMap(@(x) reshape(x, shape), {mn, h, exp(-p/.05), cleanFeat}), [], [], @meanStuffCaxis)
subplots(listMap(@(x) reshape(x, shape), {mn1, mn0, (2*isHigh-1).*exp(-p/.01), cleanFeat}), [], [], @meanStuffCaxis)
drawnow

function meanStuffCaxis(r,c,i)
% caxes = [-100 -30; -2 2; -100 -30; -100 10];
caxes = [0 1; 0 1; -1 1; -100 10];
caxis(caxes(i,:))


function keep = balanceSets(isRight, nTrain)
nStart = length(isRight);
pos = find(isRight == 1);
neg = find(isRight == -1);
numPerClass = min([length(pos) length(neg) floor(nTrain/2)]);
keep = [randomSample(pos,numPerClass); randomSample(neg,numPerClass)];
fprintf('Keeping %d of %d mixes (%d pos, %d neg)\n', ...
    length(keep), nStart, length(pos), length(neg));

function y = randomSample(x, n)
ord = randperm(length(x));
y = x(ord(1:min(end,n)));
