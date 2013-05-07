function [map features] = svmImportance(word, path, mturkOutFiles, nFold, nTrain, nAvg, thresh)

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

if ~iscell(mturkOutFiles), mturkOutFiles = {mturkOutFiles}; end
if ~exist('thresh', 'var') || isempty(thresh), thresh = 0.5; end
if ~exist('nFold', 'var') || isempty(nFold), nFold = 5; end
if ~exist('nTrain', 'var') || isempty(nTrain), nTrain = inf; end
if ~exist('nAvg', 'var') || isempty(nAvg), nAvg = inf; end

cleanFile = fullfile(path, [word '.wav']);
[mixFiles,mixPaths] = findFiles(path, [word '\d\d\.wav']);

mixFiles = mixFiles(1:min(nTrain, end));
mixPaths = mixPaths(1:min(nTrain, end));

clean = loadSpecgram(cleanFile);

features = zeros(length(mixPaths), numel(clean));
for i = 1:length(mixPaths)
    mix = loadSpecgram(mixPaths{i});
    features(i,:) = computeFeatures(clean, mix);
end

digested = {};
for i = 1:length(mturkOutFiles)
    digested = [digested; unpackMTurkCsv(mturkOutFiles{i})];
end
digested = cat(1, digested{:});

for i = 1:size(digested,1)
    if ~isempty(digested{i,2}), continue; end  % Skip rejected HITs
    ansFile{i} = basename(digested{i,3});
    isRight(i) = strncmp(ansFile{i}, digested{i,4}, length(digested{i,4}));
end

isRight = matchAnswers(mixFiles, ansFile, isRight) >= thresh;
fprintf('Average label value: %g\n', mean(isRight))

mcr = linear_train(double(isRight), sparse(features), '-s 2 -q -v 10');
mcr = crossval('mcr', features, isRight, 'Predfun', @(Xtr, ytr, Xte) libLinearPredFun(Xtr, ytr, Xte, size(clean)))
mcr = crossval('mcr', features, isRight, 'Predfun', @(Xtr, ytr, Xte) svmPredFun(Xtr, ytr, Xte, size(clean)))

svm = svmtrain(features, isRight);
map = reshape(svm.Alpha' * svm.SupportVectors, size(clean));


function preds = svmPredFun(Xtr, ytr, Xte, shape)
svm   = svmtrain(Xtr, ytr);
preds = svmclassify(svm, Xte);
subplots(reshape(svm.Alpha' * svm.SupportVectors, shape)), drawnow

function preds = libLinearPredFun(Xtr, ytr, Xte, shape)
svm = linear_train(double(ytr), sparse(Xtr), '-s 2 -q');
cls = linear_predict(zeros(size(Xte,1),1), sparse(Xte), svm, '-q');
preds = cls > 1;
%sign = (2-svm.Label(1))*2-1;
sign = 3 - 2*svm.Label(1);
subplots(sign * reshape(svm.w, shape)), drawnow


function feat = computeFeatures(clean, mix)
% Compute features for the classifier from a clean spectrogram and a mix
% spectrogram.
noise = mix - clean;
snr = db(clean) - db(noise);
%feat = reshape(snr, 1, []);
%feat = lim(reshape(snr, 1, []), -30, 30);
feat = reshape(db(noise), 1, []);

function spec = loadSpecgram(fileName)
% Load a spectrogram of a wav file
win_s = 0.064;

[x fs] = wavReadBetter(fileName);
win = round(win_s * fs);
hop = round(win/4);
spec = stft(x', win, win, hop);

function dstAns = matchAnswers(dstFiles, srcFiles, srcAns)
% For each entry in dstFile, find a match in srcFile, and return the
% corresponding element from srcAns in dstAns.
dstAns = zeros(size(dstFiles));
for i = 1:length(dstFiles)
    ind = find(strcmp(dstFiles{i}, srcFiles));
    if isempty(ind)
        error('No match found for %s', dstFiles{i});
    else
        dstAns(i) = mean(srcAns(ind));
    end
end
