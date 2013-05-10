function mcr = svmImportance(word, path, groupedFile, pcaDim, nRep, thresh, nFold, nTrain, nAvg)

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
if ~exist('nAvg', 'var') || isempty(nAvg), nAvg = inf; end
if ~exist('pcaDim', 'var') || isempty(pcaDim), pcaDim = 50; end
if ~exist('nRep', 'var') || isempty(nRep), nRep = 1; end

if numel(thresh) == 1, thresh = [thresh thresh]; end
thresh = sort(thresh);

% Should contain a variable "grouped"
load(groupedFile);
ansFile = grouped(:,3);

mixPaths = {}; fracRight = []; isRight = [];
for i = 1:length(ansFile)
    if ~reMatch(ansFile{i}, [word '\d\d\.wav']), continue, end
    mixPath = fullfile(path, ansFile{i});
    cls = (grouped{i,5} >= thresh(2)) - (grouped{i,5} <= thresh(1));
    if exist(mixPath, 'file') && cls
        mixPaths{end+1} = mixPath;
        fracRight(end+1) = grouped{i,5};
        isRight(end+1) = cls;
    end
end
mixPaths = mixPaths(:); fracRight = fracRight(:); isRight = isRight(:);
fprintf('Found %d mixes\n', length(mixPaths));

cleanFile = fullfile(path, [word '.wav']);
clean = loadSpecgram(cleanFile);

%features = zeros(length(mixPaths), 2*numel(clean));
for i = 1:length(mixPaths)
    mix = loadSpecgram(mixPaths{i});
    [features(i,:) origShape] = computeFeatures(clean, mix);
end

fprintf('Average label value: %g %g\n', mean(fracRight), mean(isRight > 0))

plotMeanStuff(features, isRight > 0, origShape);

[pcs,pcaFeat] = princomp(zscore(features), 'econ');
%pcaFeat = pcaFeat(:,1:pcaDim);
%pcs = pcs(:,1:pcaDim);

%xvalArgs = {'leaveout', 1};
xvalArgs = {'kfold', 5};

for p = 1:length(pcaDim)
    fprintf('.')

    try
        svm = svmtrain(pcaFeat(:,1:pcaDim(p)), isRight);
        subplots(reshape(-(svm.Alpha' * svm.SupportVectors) * pcs(:,1:pcaDim(p))', origShape)), drawnow
    catch
        fprintf('Oops\n')
    end

    for rep = 1:nRep
        try
            %mcr(p, rep) = lassoXVal(features, fracRight, origShape)
            %mcr(p, rep) = linear_train(double(isRight), sparse(features), '-s 2 -v 41 -q');
            %mcr(p, rep) = crossval('mcr', features, isRight, 'Predfun', @(Xtr, ytr, Xte) libLinearPredFun(Xtr, ytr, Xte, origShape), xvalArgs{:})
            %mcr(p, rep) = crossval('mcr', features, isRight, 'Predfun', @(Xtr, ytr, Xte) svmPredFun(Xtr, ytr, Xte, origShape), xvalArgs{:})
            mcr(p, rep) = crossval('mcr', pcaFeat(:,1:pcaDim(p)), isRight, 'Predfun', @(Xtr, ytr, Xte) svmPredFun(Xtr, ytr, Xte, [1 pcaDim(p)]), xvalArgs{:});
            %mcr(p, rep) = crossval('mcr', features, isRight>0, 'Predfun', @ldaPredFun, xvalArgs{:})
        catch
            mcr(p, rep) = NaN;
        end
    end
end
fprintf('\n')

function preds = svmPredFun(Xtr, ytr, Xte, shape)
options = statset('MaxIter', 1e5);
svm   = svmtrain(Xtr, ytr, 'options', options);
preds = svmclassify(svm, Xte);
%subplots(reshape(svm.Alpha' * svm.SupportVectors, shape)), drawnow

function preds = svmPcaPredFun(Xtr, ytr, Xte, pcaDims, shape)
[~,rec] = pcares(zscore([Xtr; Xte]), pcaDims);
Xtr = rec(1:size(Xtr,1),:);
Xte = rec(size(Xtr,1)+1:end,:);
svm   = svmtrain(Xtr, ytr);
preds = svmclassify(svm, Xte);
%subplots(reshape(svm.Alpha' * svm.SupportVectors, shape)), drawnow

function preds = libLinearPredFun(Xtr, ytr, Xte, shape)
svm = linear_train(double(ytr), sparse(Xtr), '-s 2 -q -c 1');
cls = linear_predict(zeros(size(Xte,1),1), sparse(Xte), svm, '-q');
n = nominal(getlevels(ytr), getlabels(ytr));
preds = n(cls);
%sign = (2-svm.Label(1))*2-1;
sign = 3 - 2*svm.Label(1);
subplots(sign * reshape(svm.w, shape)), drawnow

function preds = ldaPredFun(Xtr, ytr, Xte)
preds = classify(Xte, Xtr, ytr, 'diaglinear');

function mcr = lassoXVal(X, y, shape)
[b fitinfo] = lasso(X, y, 'CV', 3, 'NumLambda', 9, 'Alpha', 0.1);
lam = fitinfo.Index1SE; % find index of suggested lambda
subplots(reshape(b(:,lam), shape));
mcr = fitinfo.MSE(lam);  % TODO: this is not right


function [feat origShape] = computeFeatures(clean, mix)
% Compute features for the classifier from a clean spectrogram and a mix
% spectrogram.
noise = mix - clean;
snr = db(clean) - db(noise);

%origFeat = snr;
%origFeat = lim(snr, -30, 30);
origFeat = -db(noise);
%origFeat = [db(noise), -snr]; 
%origFeat = max(-100, db(clean .* (db(noise) < -30))) + 0.1*randn(size(clean));

origFeat = origFeat(:,30:end-29);
origShape = size(origFeat);
feat = reshape(origFeat, 1, []);

function spec = loadSpecgram(fileName)
% Load a spectrogram of a wav file
win_s = 0.064;

[x fs] = wavReadBetter(fileName);
win = round(win_s * fs);
hop = round(win/4);
spec = stft(x', win, win, hop);


function plotMeanStuff(features, isRight, shape)

feat1 = features( isRight,:);
feat0 = features(~isRight,:);
mn1 = mean(feat1);
mn0 = mean(feat0);
sd01 = std([bsxfun(@minus, feat1, mn1); bsxfun(@minus, feat0, mn0)]);
dPrime = (mn1 - mn0) ./ sd01;

subplots(listMap(@(x) reshape(x, shape), {mn0, mn1, dPrime}))
drawnow
