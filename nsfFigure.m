function nsfFigure(svmThreshold)

% Draw a figure for my NSF proposal showing example results for one word

if ~exist('svmThreshold', 'var') || isempty(svmThreshold), svmThreshold = 0.7; end

words = {'din', 'fin', 'pin', 'sin', 'tin', 'win'};

for w = 1:length(words)
    figure(w)
    word = words{w};
    cleanName{w} = sprintf('Clean "%s"', word);
    [cleanSpec{w} svmVis{w} specs specNames] = loadAllSpecs(word, svmThreshold);
    svmName{w} = sprintf('SVM "%s"', word);

    if length(specs) == 20
        % Replace first spec with clean
        specs{1} = cleanSpec{w};
        names = [cleanName(w) specNames(2:end)];
    else
        % Prepend first clean spec
        specs = [cleanSpec(w) specs];
        names = [cleanName(w) specNames];
    end
    %specs = [{cleanSpec{w}, svmVis{w}} specs];
    %names = [{cleanName{w}, 'SVM importance'} specNames];
    subplots(specs, [], names, @singleSubplotSettings);
end
figure(length(words)+1)
subplots([cleanSpec svmVis], [-1 length(words)], [cleanName svmName], @summarySubplotSettings)


function summarySubplotSettings(r, c, i)
if r == 1
    caxis([-70 10])
end
colorbar off
if mod(i, c) ~= 1
    set(gca, 'YTickLabel', {})
end

function singleSubplotSettings(r, c, i)
caxis([-70 10])
colorbar off
if mod(i, c) ~= 1
    set(gca, 'YTickLabel', {})
end


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

