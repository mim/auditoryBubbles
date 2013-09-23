function p = speechProfile(sr, nFft, nHop, oldNoise)

% Calculate, load, or lookup the frequency profile of reference speech.
%
% p = bubbleNoiseProfile(sr, nFft, nHop, [oldNoise])
%
% Returns the profile p in linear units of amplitude in a vector that is
% nFft/2+1 points long.

if nargin < 4, oldNoise = 0; end

persistent profiles;
if ~exist('profiles', 'var'), profiles = []; end

if oldNoise == 1
    refFile = fullfile(bubbleDataRoot, 'mrt/helen/Helen_side_chunk_1.wav');
    refQuantile = 0.99;
    smoothCoef = 0;
elseif oldNoise == 2
    refFile = fullfile(bubbleDataRoot, 'mrt/drspeech/speechRef.wav');
    refQuantile = 0.97;
    smoothCoef = 0.97;
else
    refFile = fullfile(bubbleDataRoot, 'mrt/shannon/speechRef.wav');
    refQuantile = 0.97;
    smoothCoef = 0.97;
end

fieldName = sprintf('sr%d_nFft%d_nHop%d_oldNoise%d', sr, nFft, nHop, oldNoise);
if ~isfield(profiles, fieldName)
    fprintf('cache miss for %s...\n', fieldName)
    profiles.(fieldName) = profileFromWav(refFile, sr, nFft, nHop, refQuantile, smoothCoef);
end
p = profiles.(fieldName);


function q = profileFromWav(refFile, sr, nFft, nHop, refQuantile, smoothCoef)
[x srRef] = wavread(refFile);
x = resample(x, sr, srRef);
X = stft(x', nFft, nFft, nHop);
q = quantile(abs(X), refQuantile, 2);
q = filtfilt(1-smoothCoef, [1 -smoothCoef], q);
q = q / max(q);
