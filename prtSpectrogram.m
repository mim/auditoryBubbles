function prtSpectrogram(X, prtName, fs, hop_s, cmap, cax, labels, maxFreq_hz, xrange_s, varargin)

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

colormap(cmap)  % For colorbar later...
hImg = image(t_ms, f_khz, rgb);

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

% nXticks = 8;
% xticks = unique(10 * floor(linspace(0, max(t_ms)/10, nXticks+2)));
% xticks = xticks(2:end-1);
if max(t_ms) > 5000
    xticks = makeXTicks(max(t_ms), 1);
    xlab = 'Time (s)';
    tickMult = 0.001;
elseif max(t_ms) > 2500
    xticks = makeXTicks(max(t_ms), 0.5);
    xlab = 'Time (ms)';
    tickMult = 1;
elseif max(t_ms) > 1000
    xticks = makeXTicks(max(t_ms), 0.2);
    xlab = 'Time (ms)';
    tickMult = 1;
else
    xticks = makeXTicks(max(t_ms), 0.1);
    xlab = 'Time (ms)';
    tickMult = 1;
end

set(gca, 'XTick', xticks);
if labels(2)
    xlabel(xlab)
    set(gca, 'XTickLabel', xticks * tickMult);
else
    set(gca, 'XTickLabel', {});
end
if ~isempty(xrange_s)
    xlim(xrange_s*1000)
end

if labels(3)
    hcb = colorbar;
    
    % Set real colorbar for image()
    set(hImg, 'CDataMapping', 'scaled')
    set(gca, 'clim', cax);    
 
%     ticks = get(hcb, 'YTick');
%     if ticks(1) == -1  % Only for masks, which are -1:1
%         set(hcb, 'YTick', [-0.8 -0.4 0 0.4 0.8]);
%     end
end

prt(prtName, varargin{:})


function f = freqAxis_khz(nFft, fs)
f = (0:nFft/2) / nFft * fs / 1000;

function xt_ms = makeXTicks(maxT_ms, step)
maxT_s = maxT_ms / 1000;
xt_s = step:step:maxT_s-step/2;
xt_ms = xt_s * 1000;
