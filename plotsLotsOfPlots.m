function plotsLotsOfPlots(toDisk, startAt)

% Make plots from tfct data files from expWarpExtensive.
    
if ~exist('toDisk', 'var') || isempty(toDisk), toDisk = false; end
if ~exist('startAt', 'var') || isempty(startAt), startAt = 0; end

prt('ToFile', toDisk, 'StartAt', startAt, ...
    'Width', 4, 'Height', 3, 'NumberPlots', 0, ...
    'TargetDir', 'C:\Temp\data\plots\exp12_new\trim=30,length=2.2', ...
    'SaveTicks', 1, 'Resolution', 200)

fs = 44100;
hop_s = 0.016;
tfifCmap = easymap('bwr', 255);
tfifCax = [-.99 .99];
specCmap = easymap('bcyr', 255);
specCax = [-89 9];
labels = [1 1 1];

for grouping = [0]
    for doWarp = [0 1]
        for target = [1:6:36 2:6:36]
            fileName = resFileFor(grouping, doWarp, target);
            res = load(fileName);
            
            % Plot all TFIFs
            for p = 1:size(res.mat,3)
                outName = plotFileName('tfif', p, grouping, doWarp, target);
                plotSpectrogram(res.mat(:,:,p), outName, fs, hop_s, tfifCmap, tfifCax, labels);
            end
            
            % Plot all spectrograms
            for p = 1:size(res.clean,3)
                outName = plotFileName('spec', p, grouping, doWarp, target);
                plotSpectrogram(res.clean(:,:,p), outName, fs, hop_s, specCmap, specCax, labels);
            end
            
            % Plot average spectrogram
            avgSpec = db(mean(db2mag(res.clean),3));
            outName = plotFileName('specAvg', 1, grouping, doWarp, target);
            plotSpectrogram(avgSpec, outName, fs, hop_s, specCmap, specCax, labels);
            
            %noiseLevel = min(res.clean(:));  % not important -> min(clean) dB
            noiseLevel = max(res.clean(:));  % not important -> max(clean) dB

            % Plot spectrogram weighted by TFIF
            for p = 1:size(res.clean,3)
                selected = (res.clean(:,:,p) - noiseLevel) .* (res.mat(:,:,p) .* (res.mat(:,:,p) > 0)) + noiseLevel;
                outName = plotFileName('onSpec', p, grouping, doWarp, target);
                plotSpectrogram(selected, outName, fs, hop_s, specCmap, specCax, labels);
            end

            % Plot average spectrogram weighted by combined TFIF
            selected = (avgSpec - noiseLevel) .* (res.mat(:,:,end) .* (res.mat(:,:,end) > 0)) + noiseLevel;
            outName = plotFileName('onSpecAvg', 1, grouping, doWarp, target);
            plotSpectrogram(selected, outName, fs, hop_s, specCmap, specCax, labels);
        end
    end
end

function path = resFileFor(grouping, doWarp, target)

baseDir = 'C:\Temp\data\results\exp12\trim=30,length=2.2\';
path = fullfile(baseDir, ...
    sprintf('grouping=%d', grouping), ...
    sprintf('doWarp=%d', doWarp), ...
    sprintf('target=%d', target), ...
    'fn=plotTfctWrapper/res.mat');

function fileName = plotFileName(desc, p, grouping, doWarp, target)
fileName = sprintf('grouping=%d_doWarp=%d_target=%d_%s%d', ...
    grouping, doWarp, target, desc, p);

function plotSpectrogram(X, prtName, fs, hop_s, cmap, cax, labels)

% Labels: [ylabel xlabel colorbar]

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
