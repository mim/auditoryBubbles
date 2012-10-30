function p = speechProfile(sr, nFft, nHop)

% Calculate, load, or lookup the frequency profile of reference speech.
%
% p = bubbleNoiseProfile(sr, nFft, nHop)
%
% Returns the profile p in linear units of amplitude in a vector that is
% nFft/2+1 points long.

persistent profiles;
if ~exist('profiles', 'var'), profiles = []; end

refFile = 'Z:\data\mrt\Helen_side_chunk_1.wav';
refQuantile = 0.99;

fieldName = sprintf('sr%d_nFft%d_nHop%d', sr, nFft, nHop);
if ~isfield(profiles, fieldName)
    fprintf('cache miss for %s...\n', fieldName)
    [x srRef] = wavread(refFile);
    x = resample(x, sr, srRef);
    X = stft(x', nFft, nFft, nHop);
    q = quantile(abs(X), refQuantile, 2);
    q = q / max(q);
    profiles.(fieldName) = q;
end
p = profiles.(fieldName);
