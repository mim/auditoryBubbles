function [noise mask noiseSpec] = ...
    genBubbleNoise(dur_s, sr, bubblesPerSec, profile, hopFrac, ...
    sizeF_mel, sizeT_s, randomness)

% Generate noise that is localized in time and frequency

if ~exist('profile', 'var') || isempty(profile), profile = 0.064; end
if ~exist('hopFrac', 'var') || isempty(hopFrac), hopFrac = 0.25; end
if ~exist('sizeF_mel', 'var') || isempty(sizeF_mel), sizeF_mel = 0.4; end
if ~exist('sizeT_s', 'var') || isempty(sizeT_s), sizeT_s  = 0.04; end
if ~exist('bubblesPerSec', 'var') || isempty(bubblesPerSec), bubblesPerSec = 10; end
if ~exist('randomness', 'var') || isempty(randomness), randomness = 2; end

phaseIter = 10;

if numel(profile) == 1
  % Convert from seconds to samples, make sure it's odd
  nF = 1 + 2*round(profile * sr / 2);
else
  nF = length(profile);
end

dur  = round(dur_s * sr);
nFft = (nF-1)*2;
hop  = round(hopFrac * nFft);

whiteNoise = randn(1, dur + nFft);
whiteNoise = whiteNoise * 0.99 / max(abs(whiteNoise));
noiseSpec = stft(whiteNoise, nFft, nFft, hop);
nT = size(noiseSpec,2);
nBubbles = round(dur_s * bubblesPerSec);

mask = zeros(nF, nT);

freqVec_hz = (0:nF-1) * sr / nFft;
freqVec_mel = hz2erb(freqVec_hz);
%freqVec_mel = hz2mel(freqVec_hz);
timeVec_s  = ((1:nT) - 0.5) * hop / sr;

if numel(profile) == 1
  %profile = 1 ./ freqVec_hz([2 2:end])';
  profile = [0 diff(freqVec_mel)]';
  %profile = ones(nF,1);
end

[times_s freqs_mel] = meshgrid(timeVec_s, freqVec_mel);
maxMel = max(nonzeros(freqVec_mel));
minMel = min(nonzeros(freqVec_mel));

maxMelPad = max(0.5*(maxMel+minMel), maxMel - sizeF_mel*2);
minMelPad = min(0.5*(maxMel+minMel), minMel + sizeF_mel*2);

if randomness == 0
    bubbleF_mel = linspace(minMelPad, maxMelPad, nBubbles);
    bubbleT_s   = linspace(0, dur_s, nBubbles+2);
    bubbleT_s   = bubbleT_s(2:end-1);
else
    if randomness == 1
        rng('default');
    end
    randomNumbers = rand(2, nBubbles);
    bubbleF_mel = randomNumbers(1,:)*(maxMelPad-minMelPad) + minMelPad;
    bubbleT_s   = randomNumbers(2,:)*dur_s;
end

for i = 1:nBubbles
  bumpDb = -(times_s - bubbleT_s(i)).^2 / sizeT_s.^2 ...
      - (freqs_mel - bubbleF_mel(i)).^2 / sizeF_mel.^2;
  
  mask = mask + 10.^(bumpDb / 20);
end
highPassWin = freqVec_mel' > 0;

mask = bsxfun(@times, profile .* highPassWin, mask);
[noise noiseSpec] = phaseRecon(mask, noiseSpec, phaseIter, nFft, hop);
noise = noise(1:dur)';

ca = [-120 20];
doPlot = 0;
if doPlot
    if 1
        subplots(listMap(@(x) max(-120, 20*log10(abs(x))), ...
            {noiseSpec}), [1 -1])
    else
        subplot(2,1,1)
        semilogx(20*log10(abs(noiseReSpec(:, 1:min(end,200)))))
        ylim(ca)
        
        subplot(2,1,2)
        semilogx(20*log10(mask(:, 1:min(end,200))))
        ylim(ca)
        
        subplot 111
    end
end