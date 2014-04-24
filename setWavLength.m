function x = setWavLength(x, fs, setLength_s)

% Make a wav file a certain length by zero padding or chopping off the ends
%
% x = setWavLength(x, fs, setLength_s)
%
% x is a matrix of size nSamp x nChan. It will end up either zero padded
% equally before and after or having both the beginning and end chopped off
% to get a segment from the middle of the right length.

nChan = size(x,2);
nSamp = round(setLength_s * fs);
if length(x) < nSamp
    toAdd = nSamp - length(x);
    x = [zeros(ceil(toAdd/2),nChan); x; zeros(floor(toAdd/2),nChan)];
elseif length(x) > nSamp
    toCut = length(x) - nSamp;
    x = x(floor(toCut/2) : end-ceil(toCut/2)+1, :);
end
