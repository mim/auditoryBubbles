function nsfFigure(word, svmThreshold)

% Draw a figure for my NSF proposal showing example results for one word

if ~exist('word', 'var') || isempty(word), word = 'fin'; end
if ~exist('svmThreshold', 'var') || isempty(svmThreshold), svmThreshold = 0.7; end

cleanName = sprintf('Clean "%s"', word);
[cleanSpec svmVis specs specNames] = loadAllSpecs(word, svmThreshold);

specs = [{cleanSpec, svmVis} specs];
names = [{cleanName, 'SVM importance'} specNames];
subplots(specs, [], names)%, @(c,r,i) caxis([-70 10]));


function [cleanSpec svmVis specs specNames] = loadAllSpecs(word, svmThreshold)

win_s = 0.032;
cleanFile = fullfile('Z:\data\mrt\helenWords01', [word '.wav']);

[R uPaths Rr cr] = summarizeResults('', word);
drawnow

cleanSpec = loadSpectrogram(cleanFile, win_s, 1);
for i = 1:length(uPaths)
    specs{i} = loadSpectrogram(uPaths{i}, win_s, 0);
    features{i} = reshape(specs{i} - cleanSpec, 1, []);
    specNames{i} = sprintf('Correct: %g%%', round(100*cr(i)));
end

features = cat(1, features{:});
svm = svmtrain(features, cr > svmThreshold);
svmVis = reshape(svm.Alpha' * svm.SupportVectors, size(specs{1}));


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
