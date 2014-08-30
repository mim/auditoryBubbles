function [mix targetSr clean] = mixBubbleNoise(cleanFile, targetSr, useHoles, bubblesPerSec, snr, dur_s, normalize, noiseShape, randomness)

% SNR is in linear units

if ~exist('normalize', 'var') || isempty(normalize), normalize = 1; end
if ~exist('noiseShape', 'var') || isempty(noiseShape), noiseShape = 0; end
if ~exist('randomness', 'var') || isempty(randomness), randomness = 1; end

scale_dB = 6;
speechRms = 0.1;

if useHoles
    sizeF_erb = 0.4;
    sizeT_s = 0.02;
else
    sizeF_erb = 0.4;
    sizeT_s = 0.04;
end

[speech sr] = wavread(cleanFile);
speech = mean(speech,2);
if targetSr <= 0
    targetSr = sr;
end
speech = resample(speech, targetSr, sr);

if normalize
    speech = speech * speechRms / rmsNonZero(speech, -60);
end

dur = round(dur_s * targetSr);
pad = dur - length(speech);
speech = [zeros(ceil(pad/2),1); speech; zeros(floor(pad/2),1)];

scale = 10^(scale_dB/20);
noise = genBubbleNoise(dur_s, targetSr, bubblesPerSec, useHoles, sizeF_erb, sizeT_s, [], [], randomness, noiseShape);
mix = scale * (snr*speech + noise);
clean = scale * snr * speech;

specgram(mix, 1024, targetSr, 1024, 1024-256), colorbar, drawnow
%plot(mix), drawnow
