function nsfFigure(word, svmThreshold)

% Draw a figure for my NSF proposal showing example results for one word

if ~exist('word', 'var') || isempty(word), word = 'fin'; end
if ~exist('svmThreshold', 'var') || isempty(svmThreshold), svmThreshold = 0.7; end

%function [cleanSpec svmVis specs specNames] = loadSpecs(word, svmThreshold)

win_s = 0.032;
cleanFile = fullfile('Z:\data\mrt\helenWords01', [word '.wav']);

[R uPaths Rr cr] = summarizeResults('', word);
drawnow

cleanSpec = loadSpectrogram(cleanFile, win_s, 1);
X{1} = cleanSpec;
names{1} = sprintf('Clean "%s"', word);
for i = 1:length(uPaths)
    X{i+1} = loadSpectrogram(uPaths{i}, win_s, 0);
    features{i} = reshape(X{i+1} - cleanSpec, 1, []);
    names{i+1} = sprintf('Correct: %g%%', round(100*cr(i)));
end

features = cat(1, features{:});
svm = svmtrain(features, cr > svmThreshold);
svmVis = reshape(svm.Alpha' * svm.SupportVectors, size(X{1}));

X = [X(1) {svmVis} X(2:end)];
names = [names(1) {'SVM importance'} names(2:end)];

subplots(X, [], names)%, @(c,r,i) caxis([-70 10]));



function X = loadSpectrogram(path, win_s, doScale)

speechRms = 0.1;
len_s = 0.65;
snr = db2mag(-30);

[x fs] = wavread(path);
x = setSignalLen(x, fs, len_s);

if doScale
    x = x * snr * speechRms / rmsNonZero(x, -60);
end

nFft = round(win_s * fs);
hop = round(nFft / 4);
X = max(-70, db(stft(x', nFft, nFft, hop)));
