function [map features] = svmImportance(word, path, groupedFile, nFold, nTrain, nAvg, thresh)

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

if ~exist('thresh', 'var') || isempty(thresh), thresh = 0.5; end
if ~exist('nFold', 'var') || isempty(nFold), nFold = 5; end
if ~exist('nTrain', 'var') || isempty(nTrain), nTrain = inf; end
if ~exist('nAvg', 'var') || isempty(nAvg), nAvg = inf; end

% Should contain a variable "grouped"
load(groupedFile);
ansFile = grouped(:,3);

mixPaths = {}; fracRight = [];
for i = 1:length(ansFile)
    if ~reMatch(ansFile{i}, [word '\d\d\.wav']), continue, end
    mixPath = fullfile(path, ansFile{i});
    if exist(mixPath, 'file')
        mixPaths{end+1} = mixPath;
        fracRight(end+1) = grouped{i,5};
    end
end
mixPaths = mixPaths(:); fracRight = fracRight(:);
fprintf('Found %d mixes\n', length(mixPaths));

cleanFile = fullfile(path, [word '.wav']);
clean = loadSpecgram(cleanFile);

%features = zeros(length(mixPaths), 2*numel(clean));
for i = 1:length(mixPaths)
    mix = loadSpecgram(mixPaths{i});
    [features(i,:) origShape] = computeFeatures(clean, mix);
end

isRight = fracRight >= thresh;
fprintf('Average label value: %g %g\n', mean(fracRight), mean(isRight))

mcr = lassoXVal(features, fracRight, origShape)
%mcr = linear_train(double(isRight), sparse(features), '-s 2 -v 50 -q');
%mcr = crossval('mcr', features, isRight, 'Predfun', @(Xtr, ytr, Xte) libLinearPredFun(Xtr, ytr, Xte, origShape), 'leaveout', 1)
%mcr = crossval('mcr', features, isRight, 'Predfun', @(Xtr, ytr, Xte) svmPredFun(Xtr, ytr, Xte, origShape), 'leaveout', 1)

svm = svmtrain(features, isRight);
map = reshape(svm.Alpha' * svm.SupportVectors, origShape);


function preds = svmPredFun(Xtr, ytr, Xte, shape)
svm   = svmtrain(Xtr, ytr);
preds = svmclassify(svm, Xte);
subplots(reshape(svm.Alpha' * svm.SupportVectors, shape)), drawnow

function preds = libLinearPredFun(Xtr, ytr, Xte, shape)
svm = linear_train(double(ytr), sparse(Xtr), '-s 2 -q -c 1');
cls = linear_predict(zeros(size(Xte,1),1), sparse(Xte), svm, '-q');
preds = cls > 1;
%sign = (2-svm.Label(1))*2-1;
sign = 3 - 2*svm.Label(1);
%subplots(sign * reshape(svm.w, shape)), drawnow

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
origFeat = db(noise);
%origFeat = [db(noise), -snr]; 
origShape = size(origFeat);
feat = reshape(origFeat, 1, []);

function spec = loadSpecgram(fileName)
% Load a spectrogram of a wav file
win_s = 0.064;

[x fs] = wavReadBetter(fileName);
win = round(win_s * fs);
hop = round(win/4);
spec = stft(x', win, win, hop);
