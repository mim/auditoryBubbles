function [noise mask noiseSpec] = ...
      genBubbleNoise(dur_s, sr, profile, hopFrac, ...
                     sizeF_mel, sizeT_s, bubblesPerSec)

% Generate noise that is localized in time and frequency

if ~exist('hopFrac', 'var') || isempty(hopFrac), hopFrac = 0.1; end
if ~exist('sizeF_mel', 'var') || isempty(sizeF_mel), sizeF_mel = 2; end
if ~exist('sizeT_s', 'var') || isempty(sizeT_s), sizeT_s  = 0.05; end
if ~exist('bubblesPerSec', 'var') || isempty(bubblesPerSec), bubblesPerSec = 10; end

if numel(profile) == 1
  nF = profile;
else
  nF = length(profile)
end

dur  = round(dur_s * sr);
nFft = (nF-1)*2;
hop  = round(hopFrac * nFft);

whiteNoise = randn(1, dur);
whiteNoise = whiteNoise * 0.99 / max(abs(whiteNoise));
noiseSpec = stft(whiteNoise, nFft, nFft, hop);
nT = size(noiseSpec,2);
%nT   = ceil(dur / hop);
nBubbles = dur_s * bubblesPerSec;

mask = zeros(nF, nT);

freqVec_hz = (0:nF-1) * sr / nFft;
%freqVec_mel = hz2erb(freqVec_hz);
freqVec_mel = hz2mel(freqVec_hz);
timeVec_s  = ((1:nT) - 0.5) * hop / sr;

if numel(profile) == 1
%  profile = 1 ./ freqVec_hz([2 2:end])';
%  profile = [0 diff(freqVec_mel)]';
  profile = ones(nF,1);
end

[times_s freqs_mel] = meshgrid(timeVec_s, freqVec_mel);
maxMel = max(nonzeros(freqVec_mel));
minMel = min(nonzeros(freqVec_mel));

maxMelPad = max(0.5*(maxMel+minMel), maxMel - sizeF_mel*2);
minMelPad = min(0.5*(maxMel+minMel), minMel + sizeF_mel*2);

if 0
rand('twister', 22);
bubbleF_mel = rand(1,nBubbles)*(maxMelPad-minMelPad) + minMelPad;
bubbleT_s   = rand(1,nBubbles)*dur_s;
else
bubbleF_mel = linspace(minMelPad, maxMelPad, nBubbles);
bubbleT_s   = linspace(0, dur_s, nBubbles+2);
bubbleT_s   = bubbleT_s(2:end-1);
end

for i = 1:nBubbles
  exponent = (times_s - bubbleT_s(i)).^2 / sizeT_s.^2 ...
      + (freqs_mel - bubbleF_mel(i)).^2 / sizeF_mel.^2;
  %exponent(exponent > 15) = 15;

  mask = mask + exp(-exponent);
end
highPassWin = freqVec_mel' > 0;

noiseSpec = bsxfun(@times, profile .* highPassWin, noiseSpec .* mask);
noise = istft(noiseSpec, nFft, nFft, hop);

noiseReSpec = stft(noise, 1024, 1024, 256);

ca = [-120 20];
if 1
subplot(3,1,1)
imagesc(20*log10(abs(noiseReSpec)))
axis xy
caxis(ca)
colorbar

subplot(3,1,2)
imagesc(20*log10(mask))
caxis(ca)
axis xy
colorbar

subplot(3,1,3)
imagesc(20*log10(abs(noiseSpec)))
caxis(ca)
axis xy
colorbar

else
subplot(2,1,1)
semilogx(20*log10(abs(noiseReSpec(:, 1:min(end,200)))))
ylim(ca)

subplot(2,1,2)
semilogx(20*log10(mask(:, 1:min(end,200))))
ylim(ca)
end
