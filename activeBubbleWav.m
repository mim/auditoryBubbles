function [mix clean fs bubbleF_erb bubbleT_s] = activeBubbleWav(wavFile, dur_s, snr_db, playAll, noiseShape, maxFreq_hz, window_s, hopFrac)

% Generate bubble mixture from GUI interaction with user

if ~exist('window_s', 'var') || isempty(window_s), window_s = 0.064; end
if ~exist('hopFrac', 'var') || isempty(hopFrac), hopFrac = 0.25; end
if ~exist('noiseShape', 'var') || isempty(noiseShape), noiseShape = 0; end
if ~exist('maxFreq_hz', 'var'), maxFreq_hz = []; end
if ~exist('playAll', 'var') || isempty(playAll), playAll = false; end

sizeF_erb = [];
sizeT_s   = [];
makeHoles = true;
normalizeClean = true;
cx = [-80 30];
scale_db = 6;

[x fs] = loadCleanWav(wavFile, dur_s, normalizeClean, -1);

[nF,nT,nFft,nHop,freqVec_hz,freqVec_erb,timeVec_s] = ...
    specgramDims(dur_s, fs, window_s, hopFrac, sizeF_erb);
if isempty(maxFreq_hz), maxFreq_hz = max(freqVec_hz); end

% Make visualization
X = stft([x' zeros(size(x,2),nFft)], nFft, nFft, nHop);
mask = ones(size(X));
showMaskedSpec(X, mask, timeVec_s, freqVec_hz, maxFreq_hz, cx);

bubbleT_s = []; bubbleF_erb = [];
while true
  % Get click from user
  [xc,yc,bc] = ginput(1);
  if bc ~= 1
      break
  end
  bubbleT_s(end+1) = xc;
  bubbleF_erb(end+1) = hz2erb(yc);

  % Update visualization
  mask = genMaskFromBubbleLocs(nF, nT, freqVec_erb, timeVec_s, bubbleF_erb, ...
      bubbleT_s, sizeT_s, sizeF_erb, makeHoles);
  showMaskedSpec(X, mask, timeVec_s, freqVec_hz, maxFreq_hz, cx)
  
  if playAll
      % Play sounds as you go
      mix = generateSound(x, dur_s, fs, mask, snr_db, scale_db, window_s, hopFrac, noiseShape);
      sound(mix, fs)
  end
end

% Generate sound
[mix clean] = generateSound(x, dur_s, fs, mask, snr_db, scale_db, window_s, hopFrac, noiseShape);


function showMaskedSpecSep(X, mask, timeVec_s, freqVec_hz, maxFreq_hz, cx)
subplot(1, 2, 1)
imagesc(timeVec_s, freqVec_hz, db(X));
axis xy; ylim([0 maxFreq_hz]); caxis(cx); colorbar

subplot(1, 2, 2)
imagesc(timeVec_s, freqVec_hz, mask);
axis xy; ylim([0 maxFreq_hz]); caxis([0 1]); colorbar


function showMaskedSpec(X, mask, timeVec_s, freqVec_hz, maxFreq_hz, cx)
mask_db = db(mask);
maskLims = [-80 0];
rescaledMask = lim((mask_db - maskLims(1)) / (maskLims(2) - maskLims(1)), 0, 1);
rescaledSpec = lim((db(X) - cx(1)) /  (cx(2) - cx(1)), 0, 1);
h = zeros(size(mask));
s = 1 - rescaledSpec;
v = 1 - 0.5 * rescaledMask;
%v = ones(size(mask));
rgb = hsv2rgb(cat(3,h,s,v));
image(timeVec_s, freqVec_hz, rgb);
axis xy; ylim([0 maxFreq_hz]);


function [mix clean noise] = generateSound(x, dur_s, fs, mask, snr_db, scale_db, window_s, hopFrac, noiseShape)
[~,~,noise] = genMaskedSsn(dur_s, fs, mask, window_s, hopFrac, noiseShape);
mix = 10^(scale_db/20) * (10^(snr_db/20) * x + noise);
clean = 10^(scale_db/20) * 10^(snr_db/20) * x;
