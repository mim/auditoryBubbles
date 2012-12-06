function mixMrtBubbleNoiseDir(speechFiles, nReps, bubblesPerSec, outDir, dur_s, inDir)

if ~exist('outDir', 'var') || isempty(outDir), outDir = 'Z:\data\mrt\mixes\helenWords01\'; end
if ~exist('inDir', 'var') || isempty(inDir), inDir = 'Z:\data\mrt\helenWords01'; end
if ~exist('speechFiles', 'var') || isempty(speechFiles), speechFiles = findFiles(inDir, '\.wav'); end
if ~exist('bubblesPerSec', 'var'), bubblesPerSec = 15; end
if ~exist('nReps', 'var') || isempty(nReps), nReps = 1; end
if ~exist('dur_s', 'var') || isempty(dur_s), dur_s = 2; end

useHoles = true;
snr = db2mag(-30);

for i = 1:length(speechFiles)
    cleanFile = fullfile(inDir, speechFiles{i});
    [~,sr] = wavread(cleanFile);
    
    for r = 1:nReps
        [d f e] = fileparts(speechFiles{i});
        outFile = fullfile(outDir, sprintf('bps%g', bubblesPerSec), d, ...
            sprintf('%s%02d%s', f, r, e));
        fprintf('%d %d: %s\n', i, r, outFile)
        
        [mix sr] = mixBubbleNoise(cleanFile, sr, useHoles, bubblesPerSec, snr, dur_s);
        
        ensureDirExists(outFile);
        wavwrite(mix, sr, outFile);
    end
end
