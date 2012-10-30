function [x spec] = phaseRecon(targetMag, initialPhase, nIter, nFft, hop)

% Reconstruct a signal from a target magnitude spectrogram and initial
% phase.  Does several reconstructions, keeping the phase from the last
% reconstruction with the target magnitude.

targetMag = abs(targetMag);
phase = initialPhase ./ abs(initialPhase);

for i = 1:nIter
    x = istft(targetMag .* phase, nFft, nFft, hop);
    spec = stft(x, nFft, nFft, hop);
    phase = spec ./ abs(spec);
    
    if 0
        subplots({angle(phase), angle(initialPhase), angle(phase./initialPhase)});
%         subplots([listMap(@(x) max(-120, 20*log10(abs(x))), ...
%             {spec, targetMag}), {angle(phase), angle(initialPhase)}]);
        title(num2str(i))
        pause(.5)
    end
end
