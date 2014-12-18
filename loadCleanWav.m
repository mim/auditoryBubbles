function [speech targetSr] = loadCleanWav(cleanFile, dur_s, normalize, targetSr)

% SNR is in linear units (not dB)

speechRms = 0.1;

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
