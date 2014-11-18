function p = speechProfile(sr, nFft, nHop, noiseShape)

% Calculate, load, or lookup the frequency profile of reference speech.
%
% p = bubbleNoiseProfile(sr, nFft, nHop, [noiseShape])
%
% Returns the profile p in linear units of amplitude in a vector that is
% nFft/2+1 points long.

if nargin < 4, noiseShape = 0; end

persistent profiles;
if ~exist('profiles', 'var'), profiles = []; end

if noiseShape == 1
    refFile = fullfile(bubbleDataRoot, 'mrt/helen/Helen_side_chunk_1.wav');
    refQuantile = 0.99;
    smoothCoef = 0;
elseif noiseShape == 2
    refFile = fullfile(bubbleDataRoot, 'mrt/drspeech/speechRef.wav');
    refQuantile = 0.97;
    smoothCoef = 0.97;
elseif noiseShape == 3
    refFile = fullfile(bubbleDataRoot, 'mrt/instrumentsSingle/calibration/all.wav');
    refQuantile = 0.98;
    smoothCoef = 0.995;
elseif noiseShape == 4;
    refFile = fullfile(bubbleDataRoot, 'mrt/mimWithPitt/combined.wav');
    refQuantile = 0.97;
    smoothCoef = 0.97;
else
    refFile = fullfile(bubbleDataRoot, 'mrt/shannon/speechRef.wav');
    refQuantile = 0.97;
    smoothCoef = 0.97;
end

fieldName = sprintf('sr%d_nFft%d_nHop%d_noiseShape%d', sr, nFft, nHop, noiseShape);
if ~isfield(profiles, fieldName)
    fprintf('cache miss for %s...\n', fieldName)
    profiles.(fieldName) = profileFromWav(refFile, sr, nFft, nHop, refQuantile, smoothCoef);
end
p = profiles.(fieldName);


function q = profileFromWav(refFile, sr, nFft, nHop, refQuantile, smoothCoef)
[x srRef] = wavread(refFile);
x = mean(x,2);
x = resample(x, sr, srRef);
X = stft(x', nFft, nFft, nHop);
q = quantile(abs(X), refQuantile, 2);
q = filtfilt(1-smoothCoef, [1 -smoothCoef], q);
q = q / max(q);
