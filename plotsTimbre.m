function plotsTimbre(groupedName, toDisk, startAt, allLabels)

% Make plots from tfct data files from expWarpExtensive.

if ~exist('groupedName', 'var') || isempty(groupedName), groupedName = 'mim100'; end
if ~exist('toDisk', 'var') || isempty(toDisk), toDisk = false; end
if ~exist('startAt', 'var') || isempty(startAt), startAt = 0; end
if ~exist('allLabels', 'var') || isempty(allLabels), allLabels = true; end

inDir = fullfile('C:\Temp\data\timbre\v1', groupedName, 'expWarpOut');
outDir = fullfile('C:\Temp\data\plots\timbreV1', groupedName);

prt('ToFile', toDisk, 'StartAt', startAt, ...
    'Width', 3, 'Height', 3, 'NumberPlots', 0, ...
    'TargetDir', outDir, ...
    'SaveTicks', 1, 'Resolution', 200)
%    'Width', 2, 'Height', 1.5, 'NumberPlots', 0, ...

fs = 44100;
hop_s  = 0.016;
nfft_s = 0.064;
tfifCmap = easymap('bwr', 255);
tfifCax = [-.99 .99];
specCmap = easymap('bcyr', 255);
specCax = [-100 5];
trim = 30;
length_s = 2.2;

nfft = round(nfft_s * fs);
hop  = round(hop_s * fs);
% plotExamplesDir = 'D:\Box Sync\bubblesShannon\plotExamples';
% [exFiles exPaths] = findFiles(plotExamplesDir, '.*.wav');
% [cleanExFiles cleanExPaths] = findFiles(plotExamplesDir, 'bpsInf.*.wav');
% exFiles = [cleanExFiles; setdiff(exFiles, cleanExFiles)];
% exPaths = [cleanExPaths; setdiff(exPaths, cleanExPaths)];
% for i=1:length(exFiles)
%     [x fse]  = wavReadBetter(exPaths{i});
%     x = setWavLength(x, fse, length_s);
%     X = stft(x', nfft, nfft, hop);
%     if i == 1
%         Xc = X(:,trim+1:end-trim);
%     else
%         plotSpectrogram(db(X(:,trim+1:end-trim) - Xc), [basename(exFiles{i}, 0) '_noise'], fse, hop_s, specCmap, specCax, [1 1 1]);
%     end
%     plotSpectrogram(db(X(:,trim+1:end-trim)), basename(exFiles{i}, 0), fse, hop_s, specCmap, specCax, [1 1 1]);
% end


for grouping = 0
    for doWarp = 0
        for target = 1:7
            fileName = resFileFor(inDir, grouping, doWarp, target);
            res = load(fileName);
            res.mat(isnan(res.mat)) = 0;
            res.clean = max(-120, res.clean);
            
            numDiffPlots = res.numDiffWords;
%             res.mat = res.mat(:,:,[(1:end-numDiffPlots-1) end]);
%             res.clean = res.clean(:,:,1:end-numDiffPlots);
            
            % Plot all spectrograms
            for p = 1:size(res.clean,3)
                outName = plotFileName('spec', p, grouping, doWarp, target);
                plotSpectrogram(res.clean(:,:,p), outName, fs, hop_s, specCmap, specCax, labelsFor(p==3, 0, 0, allLabels));
            end
            
            % Plot all TFIFs
            for p = 1:size(res.mat,3)
                outName = plotFileName('tfif', p, grouping, doWarp, target);
                plotSpectrogram(res.mat(:,:,p), outName, fs, hop_s, tfifCmap, tfifCax, labelsFor(p==3, 1, 0, allLabels));
            end
            
            %noiseLevel = min(res.clean(:));  % not important -> min(clean) dB
            noiseLevel = max(res.clean(:));  % not important -> max(clean) dB

            % Plot spectrogram weighted by TFIF
            for p = 1:size(res.clean,3)
                selected = (res.clean(:,:,p) - noiseLevel) .* (res.mat(:,:,p) .* (res.mat(:,:,p) > 0)) + noiseLevel;
                outName = plotFileName('onSpec', p, grouping, doWarp, target);
                plotSpectrogram(selected, outName, fs, hop_s, specCmap, specCax, labelsFor(p==3, 1, 0, allLabels));
            end
        end
    end
end

function path = resFileFor(baseDir, grouping, doWarp, target)

path = fullfile(baseDir, ...
    sprintf('grouping=%d', grouping), ...
    sprintf('doWarp=%d', doWarp), ...
    sprintf('target=%d', target), ...
    'fn=plotTfctWrapper/res.mat');

function fileName = plotFileName(desc, p, grouping, doWarp, target)
% fileName = sprintf('grouping=%d_doWarp=%d_target=%d_%s%d', ...
%     grouping, doWarp, target, desc, p);
names = {'Cello', 'Harp', 'Harpsichord', 'Marimba', 'Piano', 'TubularBells', 'Vibraphone'};
fileName = sprintf('%s_%s%d', names{target}, desc, p);

function labs = labelsFor(y, x, c, allLabels)
if allLabels
    labs = [1 1 1];
else
    labs = [y x c];
end

function plotSpectrogram(X, prtName, fs, hop_s, cmap, cax, labels)

% Labels: [ylabel xlabel colorbar]
clf  % Need this to make plots the right size for some reason...

f_khz = freqAxis_khz((size(X,1)-1)/2, fs);
ylab = 'Frequency (kHz)';
t_ms = (0:size(X,2)-1) * hop_s * 1000;

colormap(cmap)
imagesc(t_ms, f_khz, X)
caxis(cax)
axis xy
axis tight
set(gca, 'YTick', [2:2:fs/2000-1]);
if labels(1)
    set(gca, 'YTickLabel', [2:2:fs/2000-1]);
    ylabel(ylab)
else
    set(gca, 'YTickLabel', {});
end

xticks = 200:200:200*floor(max(t_ms)/200);
set(gca, 'XTick', xticks);
if labels(2)
    xlabel('Time (ms)')
    set(gca, 'XTickLabel', xticks);
else
    set(gca, 'XTickLabel', {});
end

if labels(3)
    hcb = colorbar;
    ticks = get(hcb, 'YTick');
    if ticks(1) == -1  % Only for masks, which are -1:1
        set(hcb, 'YTick', [-0.8 -0.4 0 0.4 0.8]);
    end
end

prt(prtName)


function f = freqAxis_khz(nFft, fs)
f = (0:nFft/2) / nFft * fs / 1000;
