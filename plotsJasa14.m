function plotsJasa14(toDisk, startAt)

if ~exist('toDisk', 'var') || isempty(toDisk), toDisk = false; end
if ~exist('startAt', 'var') || isempty(startAt), startAt = 0; end

outDir = '~/work/papers/jasa14/pics4/';
prt('ToFile', toDisk, 'StartAt', startAt, ...
    'Width', 2, 'Height', 2, 'NumberPlots', 0, ...
    'TargetDir', outDir, ...
    'SaveTicks', 1, 'Resolution', 200)

inDir = '/home/data/bubblesResults/preExp/pre2/trim=15,length=0/pca_100dims_1000files/res';
plotTfifs(inDir, 'repeatedAda_onSpecTr', ...
    @(x) reMatch(x, 'grouped_pre2[^s]'), ...
    @(x) reMatch(x, 'grouped_pre2sub1'), ...
    @(x) 1);

inDir = '/home/data/bubblesResults/origExp/trim=30,length=2.2/pca_100dims_1000files/res';
plotTfifs(inDir, 'figAllTfifs_onSpecTr', ...
    @(x) reMatch(x, 'w5_'), ...
    @(x) reMatch(x, 'a(ch|d|j|t|v)a_w3_01|afa_w3_02'), ...
    @(x) reMatch(x, 'ava_'));


function plotTfifs(inDir, nameExt, isRightCol, isLeftCol, isBottomRow)
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
        prtSpectrogram(cat(3,res.clean(:,:,p), res.mat(:,:,p)), outName, fs, hop_s, specCmap, specCax, labels, maxFreq);
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
