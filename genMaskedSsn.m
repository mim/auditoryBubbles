function [noiseSpec mask noise] = genMaskedSsn(dur_s, sr, mask, window_s, hopFrac, noiseShape)

% Generate speech-shaped noise with a mask applied to it
%
% function [noise mask noiseSpec] = genMaskedSsn(dur_s, sr, mask, window_s, hopFrac, noiseShape)

if ~exist('mask', 'var'), mask = []; end
if ~exist('window_s', 'var') || isempty(window_s), window_s = 0.064; end
if ~exist('hopFrac', 'var') || isempty(hopFrac), hopFrac = 0.25; end
if ~exist('noiseShape', 'var') || isempty(noiseShape), noiseShape = 0; end
fadeOut_s = 0.016;

phaseIter = 3;

% Convert from seconds to samples, make sure it's even
nFft = 2*round(window_s * sr / 2);
dur  = round(dur_s * sr);
hop  = round(hopFrac * nFft);

profile = speechProfile(sr, nFft, hop, noiseShape);

whiteNoise = randn(1, dur + nFft);
whiteNoise = whiteNoise * 0.99 / max(abs(whiteNoise));
noiseSpec = stft(whiteNoise, nFft, nFft, hop);

if isempty(mask), mask = ones(size(noiseSpec)); end

mask = bsxfun(@times, profile, mask);
mask = cat(2, mask, repmat(mask(:,end), 1, size(noiseSpec,2) - size(mask,2)));
noiseSpec = mask .* noiseSpec;
if nargout > 2
    [noise noiseSpec] = phaseRecon(noiseSpec, noiseSpec, phaseIter, nFft, hop);
    noise = noise(1:dur)';
    
    fadeOut = round(fadeOut_s * sr);
    noise(end-fadeOut:end) = ((fadeOut:-1:0)/fadeOut)' .* noise(end-fadeOut:end);
end

doPlot = 0;
if doPlot
    subplots(listMap(@(x) max(-120, 20*log10(abs(x))), ...
        {mask, noiseSpec}), [1 -1])
end
