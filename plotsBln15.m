function plotsBln15(toDisk, startAt)

if ~exist('toDisk', 'var') || isempty(toDisk), toDisk = false; end
if ~exist('startAt', 'var') || isempty(startAt), startAt = 0; end

hop_s = 0.016;
fs = 44100;
maxFreq = 8000;
allLabels = false;
inDir = 'C:\Temp\data\preExp\pre2\trim=15,length=0\pca_100dims_1000files\res';
outDir = 'Z:\data\plots\bln15';

prt('ToFile', toDisk, 'StartAt', startAt, ...
    'Width', 3, 'Height', 3, 'NumberPlots', 0, ...
    'TargetDir', outDir, ...
    'SaveTicks', 1, 'Resolution', 200)

tfifCmap = easymap('bwr', 255);
tfifCax = [-.99 .99];
specCmap = easymap('bcyr', 255);
specCax = [-99 5];

[~,resFiles] = findFiles(inDir, 'fn=plotPbc', 0);
for target = 1:length(resFiles)
    res = load(fullfile(resFiles{target}, 'res.mat'));
    res.pbc(isnan(res.pbc)) = 0;
    
    isRightCol = reMatch(resFiles{target}, 'ava_');
    isLeftCol = reMatch(resFiles{target}, 'acha_');
    
    % Plot all correlations
    for p = 1:size(res.mat,3)
        outName = plotFileName('corr', p, resFiles{target});
        prtSpectrogram(res.pbc(:,:,p), outName, fs, hop_s, tfifCmap, tfifCax, labelsFor(isLeftCol, 1, isRightCol, allLabels), maxFreq);

        outName = plotFileName('sigCorr', p, resFiles{target});
        sigMask = exp((2*abs(0.5-res.pval) - 1) / 0.05);
        prtSpectrogram(res.pbc(:,:,p) .* sigMask(:,:,p), outName, fs, hop_s, tfifCmap, tfifCax, labelsFor(isLeftCol, 1, isRightCol, allLabels), maxFreq);
    end
end

[~,resFiles] = findFiles(inDir, 'fn=plotTfctWrapper', 0);
for target = 1:length(resFiles)
    res = load(fullfile(resFiles{target}, 'res.mat'));
    res.mat(isnan(res.mat)) = 0;
    res.clean = max(-120, res.clean);

    isRightCol = reMatch(resFiles{target}, 'ava_');
    isLeftCol = reMatch(resFiles{target}, 'acha_');
    
    % Plot all spectrograms
    for p = 1:size(res.clean,3)
        outName = plotFileName('spec', p, resFiles{target});
        prtSpectrogram(res.clean(:,:,p), outName, fs, hop_s, specCmap, specCax, labelsFor(isLeftCol, 0, isRightCol, allLabels), maxFreq);
    end
    
    % Plot all TFIFs
    for p = 1:size(res.mat,3)
        outName = plotFileName('tfif', p, resFiles{target});
        prtSpectrogram(res.mat(:,:,p), outName, fs, hop_s, tfifCmap, tfifCax, labelsFor(isLeftCol, 1, isRightCol, allLabels), maxFreq);
    end
    
    %noiseLevel = min(res.clean(:));  % not important -> min(clean) dB
    noiseLevel = max(res.clean(:));  % not important -> max(clean) dB
    
    % Plot spectrogram weighted by TFIF
    for p = 1:size(res.clean,3)
        selected = (res.clean(:,:,p) - noiseLevel) .* (res.mat(:,:,p) .* (res.mat(:,:,p) > 0)) + noiseLevel;
        outName = plotFileName('onSpec', p, resFiles{target});
        prtSpectrogram(selected, outName, fs, hop_s, specCmap, specCax, labelsFor(isLeftCol, 0, isRightCol, allLabels), maxFreq);

        outName = plotFileName('onSpecTr', p, resFiles{target});
        prtSpectrogram(cat(3,res.clean(:,:,p), res.mat(:,:,p)), outName, fs, hop_s, specCmap, specCax, labelsFor(isLeftCol, 0, isRightCol, allLabels), maxFreq);
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
