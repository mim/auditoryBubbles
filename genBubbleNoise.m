function [noise mask noiseSpec] = ...
    genBubbleNoise(dur_s, sr, bubblesPerSec, makeHoles, ...
    sizeF_erb, sizeT_s, window_s, hopFrac, randomness, noiseShape)

% Generate noise that is localized in time and frequency

if ~exist('bubblesPerSec', 'var') || isempty(bubblesPerSec), bubblesPerSec = 10; end
if ~exist('makeHoles', 'var') || isempty(makeHoles), makeHoles = false; end
if ~exist('sizeF_erb', 'var') || isempty(sizeF_erb), sizeF_erb = 0.4; end
if ~exist('sizeT_s', 'var') || isempty(sizeT_s), sizeT_s  = 0.04; end
if ~exist('window_s', 'var') || isempty(window_s), window_s = 0.064; end
if ~exist('hopFrac', 'var') || isempty(hopFrac), hopFrac = 0.25; end
if ~exist('randomness', 'var') || isempty(randomness), randomness = 1; end
if ~exist('noiseShape', 'var') || isempty(noiseShape), noiseShape = 0; end

noiseSpec = genMaskedSsn(dur_s, sr, [], window_s, hopFrac, noiseShape);
[nF nT] = size(noiseSpec);

suppressHolesTo_db = -80;

% Convert from seconds to samples, make sure it's odd
nFft = (nF-1)*2;
hop  = round(hopFrac * nFft);
nBubbles = round(dur_s * bubblesPerSec);

mask = zeros(nF, nT);

freqVec_hz = (0:nF-1) * sr / nFft;
freqVec_erb = hz2erb(freqVec_hz);
%freqVec_mel = hz2mel(freqVec_hz);
timeVec_s  = ((1:nT) - 0.5) * hop / sr;

[times_s freqs_erb] = meshgrid(timeVec_s, freqVec_erb);
maxMel = max(nonzeros(freqVec_erb));
minMel = min(nonzeros(freqVec_erb));

maxMelPad = max(0.5*(maxMel+minMel), maxMel - sizeF_erb*2);
minMelPad = min(0.5*(maxMel+minMel), minMel + sizeF_erb*2);

if isfinite(nBubbles)
    if randomness == 0
        bubbleF_erb = linspace(minMelPad, maxMelPad, nBubbles);
        bubbleT_s   = linspace(0, dur_s, nBubbles+2);
        bubbleT_s   = bubbleT_s(2:end-1);
    else
        try
            if randomness == 1
                rng('shuffle');
            else
                rng(randomness);
            end
        catch ex
            warning('Could not shuffle RNG')
        end
        randomNumbers = rand(2, nBubbles);
        bubbleF_erb = randomNumbers(1,:)*(maxMelPad-minMelPad) + minMelPad;
        bubbleT_s   = randomNumbers(2,:)*dur_s;
    end

    for i = 1:nBubbles
        bumpDb = -(times_s - bubbleT_s(i)).^2 / sizeT_s.^2 ...
                 - (freqs_erb - bubbleF_erb(i)).^2 / sizeF_erb.^2;
        
        mask = mask + 10.^(bumpDb / 20);
    end
else
    % Infinite bubbles
    mask = 10.^(60/20) * ones(size(mask));
end

if makeHoles
    mask = min(1, (10^(suppressHolesTo_db/20))./mask);
end

[noiseSpec mask noise] = genMaskedSsn(dur_s, sr, mask, window_s, hopFrac, noiseShape);
