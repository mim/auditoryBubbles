function mcr = svmTrainTest(Xtr, ytr, Xte, yte, pcaDims)

% Train SVM, test SVM
preds = libLinearPredFunDimRed(Xtr, ytr, Xte, pcaDims);
mcr = 1 - classAvgAcc(yte, preds);


function [preds svm] = libLinearPredFunDimRed(Xtr, ytr, Xte, nDim)
Xtr = Xtr(:, 1:min(nDim,end));
Xte = Xte(:, 1:min(nDim,end));

svm = linear_train(double(ytr), sparse(double(Xtr)), '-s 2 -q');
preds = linear_predict(zeros(size(Xte,1),1), sparse(double(Xte)), svm, '-q');


function acc = classAvgAcc(yte, preds)
% Average accuracy in positive and negative classes, baseline 0.5
pos = (yte > 0);
neg = (yte < 0);
acc = 0.5 * mean(preds(pos) > 0) + 0.5 * mean(preds(neg) < 0);
