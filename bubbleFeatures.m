function [feat origShape weights cleanVec] = bubbleFeatures(clean, mix, fs, nFft, oldProfile, trimFrames)
% Compute features for the classifier from a clean spectrogram and a mix
% spectrogram.

if ~exist('trimFrames', 'var') || isempty(trimFrames), trimFrames = 29; end

if oldProfile
    scale_db = 14;
else
    scale_db = 6;
end

noise = mix - clean;
snr = db(clean) - db(noise);

noiseLevel = 10^(scale_db / 20) .* speechProfile(fs, nFft, round(nFft / 4), oldProfile);
noiseRel = bsxfun(@rdivide, noise, noiseLevel);

%origFeat = snr;
%origFeat = lim(snr, -30, 30);
%origFeat = -db(noise);
%origFeat = [db(noise), -snr]; 
%origFeat = max(-100, db(clean .* (db(noise) < -35))) + 0.1*randn(size(clean));
%origFeat = (db(noise) < -35) + 0.01*randn(size(clean));
%origFeat = (db(noiseRel) < -35) + 0.001*randn(size(clean));
origFeat = lim(db(noiseRel) / -80, -0.1, 1.1);

origFeat = origFeat(:, trimFrames+1:end-trimFrames);
origShape = size(origFeat);
feat = reshape(origFeat, 1, []);
cleanVec = reshape(db(clean(:, trimFrames+1:end-trimFrames)), 1, []);

freqVec_hz = (0:nFft/2) * fs / nFft;
freqVec_erb = hz2erb(freqVec_hz);
%dF = [diff(freqVec_erb) 0];
%dF = [diff(freqVec_erb) 0].^(1/2);
dF = [diff(freqVec_erb) 0].^(1/3);
%dF = [diff(freqVec_erb) 0].^(1/4);
%dF = [diff(freqVec_erb.^2) 0];
%dF = ones(1, length(freqVec_erb));
weights = repmat(dF', 1, size(origFeat,2));
weights = reshape(weights, size(feat));

