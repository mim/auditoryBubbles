function [nF nT nFft nHop freqVec_hz freqVec_erb timeVec_s minErb maxErb ...
    minErbPad maxErbPad] = specgramDims(dur_s, sr, window_s, hopFrac, sizeF_erb)

if ~exist('sizeF_erb', 'var') || isempty(sizeF_erb), sizeF_erb = 0; end

nFft = 2*round(window_s * sr / 2);
nF   = .5*nFft+1;
nHop = round(hopFrac * nFft);
dur  = round(dur_s * sr);
nT   = 1 + floor(dur / nHop);

freqVec_hz = (0:nF-1) * sr / nFft;
freqVec_erb = hz2erb(freqVec_hz);
%freqVec_mel = hz2mel(freqVec_hz);

maxErb = max(nonzeros(freqVec_erb));
minErb = min(nonzeros(freqVec_erb));

maxErbPad = max(0.5*(maxErb+minErb), maxErb - sizeF_erb*2);
minErbPad = min(0.5*(maxErb+minErb), minErb + sizeF_erb*2);
timeVec_s  = ((1:nT) - 0.5) * nHop / sr;
