function [mix targetSr clean] = mixBubbleNoise(cleanFile, targetSr, useHoles, bubblesPerSec, snr, dur_s, normalize, noiseShape, randomness)

% SNR is in linear units

if ~exist('normalize', 'var') || isempty(normalize), normalize = 1; end
if ~exist('noiseShape', 'var') || isempty(noiseShape), noiseShape = 0; end
if ~exist('randomness', 'var') || isempty(randomness), randomness = 1; end

scale_dB = 6;
scale = 10^(scale_dB/20);
[speech targetSr] = loadCleanWav(cleanFile, dur_s, normalize, targetSr);

noise = genBubbleNoise(dur_s, targetSr, bubblesPerSec, useHoles, [], [], [], [], randomness, noiseShape);
mix = scale * (snr*speech + noise);
clean = scale * snr * speech;

specgram(mix, 1024, targetSr, 1024, 1024-256), colorbar, drawnow
%plot(mix), drawnow
