function [noise mask noiseSpec] = ...
    genBubbleNoise(dur_s, sr, bubblesPerSec, makeHoles, ...
    sizeF_erb, sizeT_s, window_s, hopFrac, randomness, noiseShape)

% Generate noise that is localized in time and frequency

if ~exist('window_s', 'var') || isempty(window_s), window_s = 0.064; end
if ~exist('hopFrac', 'var') || isempty(hopFrac), hopFrac = 0.25; end
if ~exist('noiseShape', 'var') || isempty(noiseShape), noiseShape = 0; end

[nF,nT,~,~,~,freqVec_erb,timeVec_s,~,~,minErbPad,maxErbPad] = ...
    specgramDims(dur_s, sr, window_s, hopFrac, sizeF_erb);

[bubbleF_erb bubbleT_s] = genBubbleLocs(bubblesPerSec, dur_s, minErbPad, maxErbPad, randomness);

mask = genMaskFromBubbleLocs(nF, nT, freqVec_erb, timeVec_s, bubbleF_erb, ...
    bubbleT_s, sizeT_s, sizeF_erb, makeHoles);

[noiseSpec mask noise] = genMaskedSsn(dur_s, sr, mask, window_s, hopFrac, noiseShape);
