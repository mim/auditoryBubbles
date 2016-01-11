function nsfFigure(toFile, startAt)

% Draw a figure for my NSF proposal showing example results for one word

if ~exist('startAt', 'var') || isempty(startAt), startAt = 0; end
if ~exist('svmThreshold', 'var') || isempty(svmThreshold), svmThreshold = 0.7; end
words = {'din', 'fin', 'pin', 'sin', 'tin', 'win'};

prt('ToFile', toFile, 'StartAt', startAt, ...
    'Width', 8, 'Height', 9/2, ...
    'TargetDir', 'Z:\data\mrt\figsNsf', ...
    'SaveTicks', 1, 'Resolution', 200)

for w = 1:length(words)
    %figure(w)
    word = words{w};
    cleanName{w} = sprintf('Clean "%s"', word);
    [cleanSpec{w} svmVis{w} specs specNames freqFac timeFac] = loadAllSpecs(word, svmThreshold);
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
    keep = [1:4 6:9 11:20];
    subplots(specs(keep), [3 6], names(keep), @(r,c,i) singleSubplotSettings(r,c,i,freqFac,timeFac));
    prt(word)
end
%figure(length(words)+1)
subplots([cleanSpec svmVis], [-1 length(words)], [cleanName svmName], @(r,c,i) summarySubplotSettings(r,c,i,freqFac,timeFac))
prt('svm')


function summarySubplotSettings(r, c, i, freqFac, timeFac)
if r == 1
    caxis([-70 10])
end
if isLastRow(r, c, i)
    biggest = max(abs(caxis));
    caxis([-biggest biggest])
    %colormap(easymap('bwr', 256))
    %freezeColors
else
    %colormap(jet(256))
    %freezeColors
end
sharedSubplotSettings(r, c, i, freqFac, timeFac)

function singleSubplotSettings(r, c, i, freqFac, timeFac)
caxis([-70 10])
sharedSubplotSettings(r, c, i, freqFac, timeFac)

function sharedSubplotSettings(r, c, i, freqFac, timeFac)
colorbar off
if mod(i, c) ~= 1
    set(gca, 'YTickLabel', {})
else
    scaleLabels('YTickLabel', freqFac, 1);
    ylabel('Freq (Hz)')
end
if ~isLastRow(r, c, i)
    set(gca, 'XTickLabel', {})
else
    scaleLabels('XTickLabel', timeFac, 0);
    xlabel('Time (s/100)')
end

function p = isLastRow(r, c, i)
p = floor((i-1) / c) == (r-1);

function scaleLabels(labelName, scale, doRound)
curTicks = get(gca, labelName);
newTickVals = str2num(curTicks) * scale;
if doRound
    newTickVals = round(newTickVals);
end
newTicks = num2str(newTickVals);
set(gca, labelName, newTicks);


function [cleanSpec svmVis specs specNames freqFac timeFac] = loadAllSpecs(word, svmThreshold)

win_s = 0.032;
cleanFile = fullfile('Z:\data\mrt\helenWords01', [word '.wav']);

[R uPaths Rr cr] = summarizeResults('', word);
drawnow

cleanSpec = loadSpectrogram(cleanFile, win_s, 1);
for i = 1:length(uPaths)
    [specs{i} freqFac timeFac] = loadSpectrogram(uPaths{i}, win_s, 0);
    features{i} = reshape(specs{i} - cleanSpec, 1, []);
    specNames{i} = sprintf('%g%% correct', round(100*cr(i)));
end

features = cat(1, features{:});
svm = svmtrain(features, cr > svmThreshold);
svmVis = reshape(svm.Alpha' * svm.SupportVectors, size(specs{1}));


function [X freqFac timeFac] = loadSpectrogram(path, win_s, doScale)

speechRms = 0.1;
len_s = 0.65;
snr = db2mag(-30);

[x fs] = audioread(path);
x = setSignalLen(x, fs, len_s);

if doScale
    x = x * snr * speechRms / rmsNonZero(x, -60);
end

nFft = round(win_s * fs);
hop = round(nFft / 4);
X = max(-70, db(stft(x', nFft, nFft, hop)));

freqFac = fs / nFft; % Convert FFT bin to Hz
timeFac = hop / fs * 100;  % Convert frame num to s/100 (cs)
