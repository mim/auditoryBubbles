function [speech targetSr dur_s] = loadCleanWav(cleanFile, dur_s, normalize, targetSr)

% SNR is in linear units (not dB)

if ~exist('dur_s','var'), dur_s = []; end

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

if isempty(dur_s)
    dur = length(speech);
else
    dur = round(dur_s * targetSr);
end
pad = dur - length(speech);
speech = [zeros(ceil(pad/2),1); speech; zeros(floor(pad/2),1)];

dur_s = length(speech) / targetSr;
