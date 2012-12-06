function [mix targetSr] = mixBubbleNoise(cleanFile, targetSr, useHoles, bubblesPerSec, snr, dur_s)

% SNR is in linear units

noiseScale_dB = 0;
speechRms = 0.1;

if useHoles
    sizeF_erb = 0.4;
    sizeT_s = 0.02;
else
    sizeF_erb = 0.4;
    sizeT_s = 0.04;
end

[speech sr] = wavread(cleanFile);
speech = resample(speech, targetSr, sr);
speech = speech * speechRms / rmsNonZero(speech, -60);

dur = round(dur_s * sr);
pad = dur - length(speech);
speech = [zeros(ceil(pad/2),1); speech; zeros(floor(pad/2),1)];

noise = 10^(noiseScale_dB/20)*genBubbleNoise(dur_s, sr, bubblesPerSec, useHoles, sizeF_erb, sizeT_s);
mix = snr*speech + noise;

%spectrogram(mix, 1024, 1024-256, 1024, sr), drawnow
