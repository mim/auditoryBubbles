function mask = genMaskFromBubbleLocs(nF, nT, freqVec_erb, ...
    timeVec_s, bubbleF_erb, bubbleT_s, sizeT_s, sizeF_erb, makeHoles)

if ~exist('makeHoles', 'var') || isempty(makeHoles), makeHoles = false; end
if ~exist('sizeF_erb', 'var') || isempty(sizeF_erb), sizeF_erb = 0.4; end
if ~exist('sizeT_s', 'var') || isempty(sizeT_s), sizeT_s  = 0.02; end

suppressHolesTo_db = -80;

if all(isfinite(bubbleF_erb))
    [times_s freqs_erb] = meshgrid(timeVec_s, freqVec_erb);
    mask = zeros(nF, nT);
    for i = 1:length(bubbleF_erb)
        bumpDb = -(times_s - bubbleT_s(i)).^2 / sizeT_s.^2 ...
                 - (freqs_erb - bubbleF_erb(i)).^2 / sizeF_erb.^2;
        
        mask = mask + 10.^(bumpDb / 20);
    end
else
    % Infinite bubbles
    mask = 10.^((-suppressHolesTo_db - 20)/20) * ones(nF, nT);
end

if makeHoles
    mask = min(1, (10^(suppressHolesTo_db/20))./mask);
end

