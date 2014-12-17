function [bubbleF_erb bubbleT_s] = genBubbleLocs(bubblesPerSec, dur_s, minErbPad, maxErbPad, randomness)

if ~exist('bubblesPerSec', 'var') || isempty(bubblesPerSec), bubblesPerSec = 10; end
if ~exist('randomness', 'var') || isempty(randomness), randomness = 1; end

if isfinite(bubblesPerSec)
    nBubbles = round(bubblesPerSec * dur_s);
    
    if randomness == 0
        bubbleF_erb = linspace(minErbPad, maxErbPad, nBubbles);
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
        bubbleF_erb = randomNumbers(1,:)*(maxErbPad-minErbPad) + minErbPad;
        bubbleT_s   = randomNumbers(2,:)*dur_s;
    end
else
    % Infinite bubbles
    bubbleF_erb = inf;
    bubbleT_s   = inf;
end
