function prtSpectrogram(X, prtName, fs, hop_s, cmap, cax, labels, maxFreq_hz, xrange_s)

% Labels: [ylabel xlabel colorbar]
clf  % Need this to make plots the right size for some reason...

if ~exist('maxFreq_hz', 'var') || isempty(maxFreq_hz), maxFreq_hz = inf; end
if ~exist('xrange_s', 'var'), xrange_s = []; end

f_khz = freqAxis_khz((size(X,1)-1)/2, fs);
ylab = 'Frequency (kHz)';
t_ms = (0:size(X,2)-1) * hop_s * 1000;

if size(X,3) > 1
    mask = lim(X(:,:,2), 0, 1);
    X = X(:,:,1);
else
    mask = ones(size(X));
end

Xn = (X - cax(1)) / (cax(2) - cax(1));
rgb = ind2rgb(1 + round((size(cmap,1)-1) * Xn), cmap);

% Darken regions that are masked out
hsv = rgb2hsv(rgb);
hsv(:,:,3) = hsv(:,:,3) .* (0.5 * mask + 0.5); 
rgb = hsv2rgb(hsv);

image(t_ms, f_khz, rgb);

axis xy
axis tight

maxFreq_khz = min(maxFreq_hz/1000, max(f_khz));

if maxFreq_khz > 10
    yt = 2:2:maxFreq_khz-1e-3;
elseif maxFreq_khz > 5
    %yt = 0.5:0.5:maxFreq_khz-1e-3;
    yt = 1:1:maxFreq_khz-1e-3;
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
if ~isempty(xrange_s)
    xlim(xrange_s*1000)
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
