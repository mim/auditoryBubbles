function mixMrtBubbleNoiseDir(inDir, speechFiles, outDir, nReps, bubblesPerSec, dur_s)

if ~exist('bubblesPerSec', 'var'), bubblesPerSec = 10; end
if ~exist('nReps', 'var') || isempty(nReps), nReps = 1; end
if ~exist('dur_s', 'var') || isempty(dur_s), dur_s = 2; end

for i = 1:length(speechFiles)
    [speech sr] = wavread(fullfile(inDir, speechFiles{i}));
    
    dur = round(dur_s * sr);
    pad = dur - length(speech);
    speech = [zeros(ceil(pad/2),1); speech; zeros(floor(pad/2),1)];
    
    for r = 1:nReps
        [d f e] = fileparts(speechFiles{i});
        outFile = fullfile(outDir, sprintf('bps%g', bubblesPerSec), d, ...
            sprintf('%s%02d%s', f, r, e));
        fprintf('%d %d: %s\n', i, r, outFile)
        
        noise = 100*genBubbleNoise(dur_s, sr, bubblesPerSec);
        mix = speech + noise;
        
        ensureDirExists(outFile);
        wavwrite(mix, sr, outFile);
    end
end
