function prtSpectrogram(X, prtName, fs, hop_s, cmap, cax, labels, maxFreq_hz)

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

maxFreq_khz = min(maxFreq_hz/1000, max(f_khz));

if maxFreq_khz > 10
    yt = 2:2:maxFreq_khz-1e-3;
elseif maxFreq_khz > 5
    yt = 0.5:0.5:maxFreq_khz-1e-3;
else
    yt = 0.2:0.2:maxFreq_khz-1e-3;
end

set(gca, 'YTick', yt);
if labels(1)
    set(gca, 'YTickLabel', yt);
    ylabel(ylab)
else
    set(gca, 'YTickLabel', {});
end
ylim([0 maxFreq_khz])

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
