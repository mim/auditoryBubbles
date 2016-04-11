function plotsInterspeech16(toDisk, startAt)

if ~exist('toDisk', 'var') || isempty(toDisk), toDisk = false; end
if ~exist('startAt', 'var') || isempty(startAt), startAt = 0; end

outDir = '~/work/papers/interspeech16/pics2/';
prt('ToFile', toDisk, 'StartAt', startAt, ...
    'Width', 2, 'Height', 2, 'NumberPlots', 0, ...
    'TargetDir', outDir, ...
    'SaveTicks', 1, 'Resolution', 200)

inDir = '/home/data/bubblesFeat/gridAllAdapt/trim=00,length=0/pca_100dims_1000files/res/';
plotOnSpecs(inDir, 'gridAdaptAll', 'human', [-99 4], ...
    @(x) reMatch(x, 'bwir6a'), ...
    @(x) reMatch(x, 'bbikza'), ...
    @(x) reMatch(x, '_p5'));

inDir = '/home/data/bubblesFeat/asrGrid400/trim=00,length=2/pca_100dims_1000files/res';
plotOnSpecs(inDir, '', 'asr', [-99 4]+15, ...
    @(x) reMatch(x, 'bwir6a'), ...
    @(x) reMatch(x, 'bbikza'), ...
    @(x) reMatch(x, '_05'));

inDir = '/home/data/bubblesFeat/asrGrid400/trim=00,length=2/pca_100dims_1000files/res';
plotTfifs(inDir, 'bwi(r6|e8)a.*_04', 'asr', [-99 4]+15, ...
    @(x) false, ...
    @(x) reMatch(x, 'spec'), ...
    @(x) reMatch(x, 'bwie8a'));

inDir = '/home/data/bubblesFeat/gridAllAdapt/trim=00,length=0/pca_100dims_1000files/res/';
plotTfifs(inDir, 'gridAdaptAll_p4.*bwi(r6|e8)a', 'human', [-99 4], ...
    @(x) true, ...
    @(x) false, ...
    @(x) reMatch(x, 'bwie8a'));


function plotOnSpecs(inDir, pattern, nameExt, specCax, isRightCol, isLeftCol, isBottomRow)
hop_s = 0.016;
fs = 16000;
maxFreq = 8000;
allLabels = false;

specCmap = easymap('bcyr', 255);

[~,resFiles] = findFiles(inDir, [pattern '.*fn=plotTfctWrapper'], 0);
for target = 1:length(resFiles)
    res = load(fullfile(resFiles{target}, 'res.mat'));
    res.mat(isnan(res.mat)) = 0;
    res.clean = max(-120, res.clean);

    labels = labelsFor(isLeftCol(resFiles{target}), isBottomRow(resFiles{target}), isRightCol(resFiles{target}), allLabels);
    
    % Plot spectrogram weighted by TFIF
    for p = 1:size(res.clean,3)
        outName = plotFileName([nameExt '_onSpecTr'], p, resFiles{target});
        prtSpectrogram(cat(3,res.clean(:,:,p), res.mat(:,:,p)), outName, fs, hop_s, specCmap, specCax, labels, maxFreq);
    end
end

function plotTfifs(inDir, pattern, nameExt, specCax, isRightCol, isLeftCol, isBottomRow)
hop_s = 0.016;
fs = 16000;
maxFreq = 8000;
allLabels = false;

specCmap = easymap('bcyr', 255);
tfifCmap = easymap('bwr', 254);
tfifCax = [-.99 .99];

[~,resFiles] = findFiles(inDir, [pattern '.*fn=plotPbc'], 0);
for target = 1:length(resFiles)
    res = load(fullfile(resFiles{target}, 'res.mat'));
    res.mat(isnan(res.mat)) = 0;
    res.clean = max(-120, res.clean);
    
    for p = 1:size(res.clean,3)
        % Just spectrogram
        outName = plotFileName([nameExt '_spec'], p, resFiles{target});
        labels = labelsFor(isLeftCol(outName), isBottomRow(outName), isRightCol(outName), allLabels);
        prtSpectrogram(res.clean(:,:,p), outName, fs, hop_s, specCmap, specCax, labels, maxFreq);

        % Just TFIF
        outName = plotFileName([nameExt '_sigCorr'], p, resFiles{target});
        labels = labelsFor(isLeftCol(outName), isBottomRow(outName), isRightCol(outName), allLabels);
        sigMask = exp((2*abs(0.5-res.pval(:,:,p)) - 1) / 0.05);
        prtSpectrogram(res.pbc(:,:,p) .* sigMask, outName, fs, hop_s, tfifCmap, tfifCax, labels, maxFreq);
    end
end

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
