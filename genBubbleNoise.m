function [noise mask noiseSpec] = ...
      genBubbleNoise(dur_s, sr, profile, hopFrac, ...
                     bubblesSizeF_mel, bubbleSizeT_s, bubblesPerSec)

% Generate noise that is localized in time and frequency

if ~exist('hopFrac', 'var') || isempty(hopFrac), hopFrac = 0.1; end
if ~exist('bubbleSizeF_mel', 'var') || isempty(bubbleSizeF_mel), bubbleSizeF_mel = 2; end
if ~exist('bubbleSizeT_s', 'var') || isempty(bubbleSizeT_s), bubbleSizeT_s  = 0.05; end
if ~exist('bubblesPerSec', 'var') || isempty(bubblesPerSec), bubblesPerSec = 5; end

if numel(profile) == 1
  nF = profile;
else
  nF = length(profile)
end

dur  = round(dur_s * sr);
nFft = (nF-1)*2;
hop  = round(hopFrac * nFft);

whiteNoise = randn(1, dur);
noiseSpec = stft(whiteNoise, nFft, nFft, hop);

nT = size(noiseSpec,2);
%nT   = ceil(dur / hop);
nBubbles = dur_s * bubblesPerSec;

mask = zeros(nF, nT);

freqVec_hz = (0:nF-1) * sr / nF;
freqVec_mel = hz2mel(freqVec_hz);
timeVec_s  = ((1:nT) - 0.5) * hop / sr;

if numel(profile) == 1
%  profile = 1 ./ freqVec_hz([2 2:end])';
  profile = [0 diff(freqVec_mel)]';
end
%semilogx(20*log10(profile))

[times_s freqs_mel] = meshgrid(timeVec_s, freqVec_mel);
maxMel = max(freqVec_mel);
minMel = min(freqVec_mel);

rand('twister', 22);
bubbleF_mel = rand(1,nBubbles)*(maxMel-minMel) + minMel;
bubbleT_s   = rand(1,nBubbles)*dur_s;

for i = 1:nBubbles
  exponent = ((times_s - bubbleT_s(i)).^2 / bubbleSizeT_s.^2 ...
      + (freqs_mel - bubbleF_mel(i)).^2 / bubbleSizeF_mel.^2);

  mask = mask + exp(-exponent);
end

noiseSpec = bsxfun(@times, profile, noiseSpec .* mask);
noise = istft(noiseSpec, nFft, nFft, hop);
