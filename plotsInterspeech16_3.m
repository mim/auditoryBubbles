function plotsInterspeech16_3(toDisk, startAt)

if ~exist('toDisk', 'var') || isempty(toDisk), toDisk = false; end
if ~exist('startAt', 'var') || isempty(startAt), startAt = 0; end

outDir = '~/work/posters/interspeech16/posterPlots';

prt('ToFile', toDisk, 'StartAt', startAt, ...
    'Width', 2, 'Height', 2, 'NumberPlots', 0, ...
    'TargetDir', outDir, ...
    'SaveTicks', 1, 'Resolution', 200)

inDir = '/home/data/bubblesFeat/gridAllAdapt/trim=00,length=0/pca_100dims_1000files/res/';
plotOnSpecs(inDir, 'gridAdaptAll/', 'human', [-99 4], ...
    @(x) reMatch(x, 'bwir6a'), ...
    @(x) reMatch(x, 'bbikza'), ...
    @(x) true, 0);


hop_s = 0.016;
maxFreq = 8000;
specCmap = easymap('bcyr', 255);
specCax = [-99 4];

[~,files] = findFiles('/home/data/bubbles/grid/id16mix/bpsmim', '.*200.wav');
noisyToCleanFn = findNoisyToCleanFn(files{1});
for i = 1:length(files)
    f = load(strrep(files{i}, '.wav', '.mat'));
    if (f.wasRight)
        cleanFile = noisyToCleanFn(files{i});
        [noisy fs] = loadSpecgramBubbleFeats(files{i}, -1);
        [clean fs] = loadSpecgramBubbleFeats(cleanFile, -1);
        noise = noisy - clean;

        prtSpectrogram(db(clean), [basename(files{i},0) '_clean'], fs, hop_s, specCmap, specCax, [1 1 0], maxFreq);
        prtSpectrogram(db(noise), [basename(files{i},0) '_noise'], fs, hop_s, specCmap, specCax, [0 1 0], maxFreq);
        prtSpectrogram(db(noisy), [basename(files{i},0) '_noisy'], fs, hop_s, specCmap, specCax, [0 1 1], maxFreq);
    end
end


function plotOnSpecs(inDir, pattern, nameExt, specCax, isRightCol, isLeftCol, isBottomRow, allLabels)

hop_s = 0.016;
fs = 16000;
maxFreq = 8000;

specCmap = easymap('bcyr', 255);
tfifCmap = easymap('bwr', 254);
tfifCax = [-.99 .99];

% [~,resFiles] = findFiles(inDir, [pattern '.*fn=plotTfctWrapper'], 0);
% for target = 1:length(resFiles)
%     res = load(fullfile(resFiles{target}, 'res.mat'));
%     res.mat(isnan(res.mat)) = 0;
%     res.clean = max(-120, res.clean);
% 
%     labels = labelsFor(isLeftCol(resFiles{target}), isBottomRow(resFiles{target}), isRightCol(resFiles{target}), allLabels);
%     
%     % Plot spectrogram weighted by TFIF
%     for p = 1:size(res.clean,3)
%         outName = plotFileName([nameExt '_onSpecTr'], p, resFiles{target});
%         prtSpectrogram(cat(3,res.clean(:,:,p), res.mat(:,:,p)), outName, fs, hop_s, specCmap, specCax, labels, maxFreq);
%     end
% end

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
 
%         % Just TFIF
%         outName = plotFileName([nameExt '_sigCorr'], p, resFiles{target});
%         labels = labelsFor(isLeftCol(outName), isBottomRow(outName), isRightCol(outName), allLabels);
%         sigMask = exp((2*abs(0.5-res.pval(:,:,p)) - 1) / 0.05);
%         prtSpectrogram(res.pbc(:,:,p) .* sigMask, outName, fs, hop_s, tfifCmap, tfifCax, labels, maxFreq);
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
