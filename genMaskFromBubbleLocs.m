function mask = genMaskFromBubbleLocs(nF, nT, freqVec_erb, ...
    timeVec_s, bubbleF_erb, bubbleT_s, sizeT_s, sizeF_erb, makeHoles, suppressHolesTo_db, maxApprox)

if ~exist('makeHoles', 'var') || isempty(makeHoles), makeHoles = false; end
if ~exist('sizeF_erb', 'var') || isempty(sizeF_erb), sizeF_erb = 0.4; end
if ~exist('sizeT_s', 'var') || isempty(sizeT_s), sizeT_s  = 0.02; end
if ~exist('suppressHolesTo_db', 'var') || isempty(suppressHolesTo_db), suppressHolesTo_db = -80; end
if ~exist('maxApprox', 'var') || isempty(maxApprox), maxApprox = 1; end

if all(isfinite(bubbleF_erb))
    [times_s freqs_erb] = meshgrid(timeVec_s, freqVec_erb);
    
    if maxApprox
        mask = -200 * ones(nF, nT);
    else
        mask = zeros(nF, nT);
    end
    
    for i = 1:length(bubbleF_erb)
        rows = -(freqVec_erb - bubbleF_erb(i)).^2 / sizeF_erb.^2 > suppressHolesTo_db-40;
        cols = -(timeVec_s - bubbleT_s(i)).^2 / sizeT_s.^2 > suppressHolesTo_db-40;
        
        bumpDb = -(times_s(rows,cols) - bubbleT_s(i)).^2 / sizeT_s.^2 ...
            - (freqs_erb(rows,cols) - bubbleF_erb(i)).^2 / sizeF_erb.^2;
        %subplots(bumpDb); pause(.01);
        
        if maxApprox
            mask(rows,cols) = max(mask(rows,cols), bumpDb);
        else
            bumpLin = 10.^(bumpDb / 20);
            mask(rows,cols) = mask(rows,cols) + bumpLin;
        end
    end
    if maxApprox
        mask = 10.^(mask / 20);
    end
else
    % Infinite bubbles
    mask = 10.^((-suppressHolesTo_db - 20)/20) * ones(nF, nT);
end

if makeHoles
    mask = min(1, (10^(suppressHolesTo_db/20))./mask);
end

