function plotsJasa14(toDisk, startAt)

if ~exist('toDisk', 'var') || isempty(toDisk), toDisk = false; end
if ~exist('startAt', 'var') || isempty(startAt), startAt = 0; end

outDir = '~/work/papers/jasa14/pics4/';
prt('ToFile', toDisk, 'StartAt', startAt, ...
    'Width', 3, 'Height', 3, 'NumberPlots', 0, ...
    'TargetDir', outDir, ...
    'SaveTicks', 1, 'Resolution', 200)

% 2 x 3 grid: clean, noise, noisy \\ 395 397 399
inDir = '/home/mim/work/papers/jasa14/wavsToPlot';
plotWavs(inDir, 'exampleWavs', ...
    @(x) reMatch(x, '399.wav|grouped.*noise.wav'), ...
    @(x) reMatch(x, '395.wav|000.wav'), ...
    @(x) reMatch(x, '39..wav'));

% 2 x 3 grid: 1 2 3 \\ 4 5 cons
inDir = '/home/data/bubblesResults/preExp/pre2/trim=15,length=0/pca_100dims_1000files/res';
plotTfifs(inDir, 'repeatedAda_onSpecTr', ...
    @(x) reMatch(x, 'grouped_pre2(sub3|[^s])'), ...
    @(x) reMatch(x, 'grouped_pre2sub[14]'), ...
    @(x) reMatch(x, 'grouped_pre2(sub4|sub5|[^s])'));

% 1 x 6 grid: 1 2 3 4 5 cons
inDir = '/home/data/bubblesResults/preExp/pre2/trim=15,length=0/pca_100dims_1000files/res';
plotTfifs(inDir, 'repeatedAda1by6_onSpecTr', ...
    @(x) reMatch(x, 'grouped_pre2[^s]'), ...
    @(x) reMatch(x, 'grouped_pre2sub1'), ...
    @(x) 1, ...
    'width', 2, 'height', 2);

% 6 x 6 grid
inDir = '/home/data/bubblesResults/origExp/trim=30,length=2.2/pca_100dims_1000files/res';
plotTfifs(inDir, 'figAllTfifs_onSpecTr', ...
    @(x) reMatch(x, 'w5_'), ...
    @(x) reMatch(x, 'a(ch|d|j|t|v)a_w3_01|afa_w3_02'), ...
    @(x) reMatch(x, 'ava_'), ...
    'width', 2, 'height', 2);



function plotTfifs(inDir, nameExt, isRightCol, isLeftCol, isBottomRow, varargin)
hop_s = 0.016;
fs = 44100;
maxFreq = 8000;
allLabels = false;

specCmap = easymap('bcyr', 255);
specCax = [-99 5];

[~,resFiles] = findFiles(inDir, 'fn=plotTfctWrapper', 0);
for target = 1:length(resFiles)
    res = load(fullfile(resFiles{target}, 'res.mat'));
    res.mat(isnan(res.mat)) = 0;
    res.clean = max(-120, res.clean);

    labels = labelsFor(isLeftCol(resFiles{target}), isBottomRow(resFiles{target}), isRightCol(resFiles{target}), allLabels);
    
    % Plot spectrogram weighted by TFIF
    for p = 1:size(res.clean,3)
        outName = plotFileName(nameExt, p, resFiles{target});
        prtSpectrogram(cat(3,res.clean(:,:,p), res.mat(:,:,p)), outName, fs, hop_s, specCmap, specCax, labels, maxFreq, [], varargin{:});
    end
end


function plotWavs(inDir, nameExt, isRightCol, isLeftCol, isBottomRow)
maxFreq_hz = 8000;
range_s = [0.2 1.6]; %[0.5 1.7];
xRange_s = [];
allLabels = false;

specCmap = easymap('bcyr', 255);
specCax = [-99 5];

files = findFiles(inDir, '.*.wav');
for f = 1:length(files)
    name = fullfile(nameExt, basename(files{f}, 0));
    inFile = fullfile(inDir, files{f});

    labels = labelsFor(isLeftCol(files{f}), isBottomRow(files{f}), isRightCol(files{f}), allLabels);
    
    [X fs hop_s] = loadSpecgram(inFile, [], range_s);
    prtSpectrogram(db(X), name, fs, hop_s, specCmap, specCax, labels, maxFreq_hz, xRange_s, 'width', 3, 'height', 3);
end


function [X fs hop_s] = loadSpecgram(file, win_s, range_s)
if ~exist('win_s', 'var') || isempty(win_s), win_s = 0.064; end
if ~exist('range_s', 'var'), range_s = []; end

[x fs] = wavReadBetter(file);
x = x(:,1);
if ~isempty(range_s)
    range = round(range_s * fs);
    x = x(max(1, range(1)) : min(end, range(2)));
end
nfft = 2 * round(win_s * fs / 2);
hop = round(nfft / 4);
X = stft(x', nfft, nfft, hop);
hop_s = hop / fs;


function fileName = plotFileName(desc, p, target)
[d fn] = fileparts(target);
[d,utt] = fileparts(d);
[~,group] = fileparts(d);
%fileName = fullfile(fn, sprintf('%s%s%d', utt, desc, p));
fileName = sprintf('%s/%s%s%d', group, utt, desc, p);

function labs = labelsFor(y, x, c, allLabels)
if allLabels
    labs = [1 1 1];
else
    labs = [y x c];
end
