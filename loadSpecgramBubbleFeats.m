function [spec fs nfft] = loadSpecgramBubbleFeats(fileName, setLength_s)
% Load a spectrogram of a wav file
win_s = 0.064;

[x fs] = wavReadBetter(fileName);
nSamp = round(fs * setLength_s);

if nSamp > 0
    if length(x) < nSamp
        toAdd = nSamp - length(x);
        x = [zeros(ceil(toAdd/2),1); x; zeros(floor(toAdd/2),1)];
    elseif length(x) > nSamp
        toCut = length(x) - nSamp;
        x = x(floor(toCut/2) : end-ceil(toCut/2)+1);
    end
    assert(length(x) == nSamp);
end

nfft = round(win_s * fs / 2) * 2;
hop = round(nfft/4);
spec = stft(x', nfft, nfft, hop);
