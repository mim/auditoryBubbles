function [q2 minD startD] = alignCleanSigs(S1, S2, fs, nfft)

% Find the warping of S2 that best aligns it with S1.
%
% q2 = alignCleanSigs(S1, S2, fs, nfft)
%
% S1 and S2 are clean features extracted by bubbleFeatures.m (log-amplitude
% spectrograms).  Output q2 is the warping to apply to S2 to align it with
% S1, so S2(:,q2) is as close as possible to S1 in MFCC space.

M1 = mfccFromCleanFeat(S1, fs, nfft);
M2 = mfccFromCleanFeat(S2, fs, nfft);
D = bsxfun(@plus, bsxfun(@plus, -2*M1'*M2, sum(M1.^2,1)'), sum(M2.^2,1));
[p q] = dp(D);  % plot(q,p) to visualize

q2 = zeros(1,max(p));
for i=1:max(p)
    q2(i) = q(find(p == i, 1, 'first'));
end
minD = mean(sqrt(sum((M1 - M2(:,q2)).^2,1)), 2);
startD = mean(sqrt(sum((M1 - M2).^2,1)), 2);

%subplots({S1, S2, S2(:,q2)}, [], [], @(r,c,i) caxis([-100 10]))


function M = mfccFromCleanFeat(S, sr, nfft, varargin)
% Input is log-amplitude spectrogram.  Code taken from melfcc.

% Parse out the optional arguments
[numcep lifterexp sumpower preemph minfreq maxfreq nbands bwidth dcttype fbtype useenergy] = ...
    process_options(varargin, 'numcep', 13, 'lifterexp', 0.6, 'sumpower', 1, ...
    'preemph', 0.97, 'minfreq', 0, 'maxfreq', 4000, 'nbands', 40, ...
    'bwidth', 1.0, 'dcttype', 2, 'fbtype', 'mel', 'useenergy', 1);

pspectrum = 10 .^ (max(S, -70) / 10);

if preemph
    H = magSq(fft([1 -preemph]', nfft));
    pspectrum = bsxfun(@times, pspectrum, H(1:size(pspectrum,1)));
end

aspectrum = audspec(pspectrum, sr, nbands, fbtype, minfreq, maxfreq, sumpower, bwidth);

% Convert to cepstra via DCT
cepstra = spec2cep(aspectrum, numcep, dcttype);

cepstra = lifter(cepstra, lifterexp);

if useenergy
  cepstra(1,:) = log(sum(pspectrum,1));
end

M = cepstra;