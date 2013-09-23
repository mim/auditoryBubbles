function mixMrtBubbleNoiseDir(speechFiles, nMixes, bubblesPerSec, snr_db, outDir, dur_s, inDir)

if ~exist('outDir', 'var') || isempty(outDir), outDir = 'Z:\data\mrt\mixes\helenWords01\'; end
if ~exist('inDir', 'var') || isempty(inDir), inDir = 'Z:\data\mrt\helen\helenWords01'; end
if ~exist('speechFiles', 'var') || isempty(speechFiles), speechFiles = findFiles(inDir, '\.wav'); end
if ~exist('bubblesPerSec', 'var') || isempty(bubblesPerSec), bubblesPerSec = 15; end
if ~exist('snr_db', 'var') || isempty(snr_db), snr_db = -30; end
if ~exist('nMixes', 'var') || isempty(nMixes), nMixes = 1; end
if ~exist('dur_s', 'var') || isempty(dur_s), dur_s = 2; end

if ischar(speechFiles)  % Can supply a pattern
    speechFiles = findFiles(inDir, speechFiles, 1);
end

useHoles = true;
snr = db2mag(snr_db);

for i = 1:length(speechFiles)
    cleanFile = fullfile(inDir, speechFiles{i});
    [~,sr] = wavread(cleanFile);
    
    num = 0;
    while true
        [d f e] = fileparts(speechFiles{i});

        % Find next available file name
        numTaken = true;
        while numTaken
            num = num + 1;
            outFile = fullfile(outDir, sprintf('bps%g', bubblesPerSec), ...
                sprintf('snr%+d', snr_db), d, sprintf('%s_%03d%s', f, num, e));
            numTaken = exist(outFile, 'file');
        end
        if num > nMixes
            break
        end
        fprintf('%d %d: %s\n', i, num, outFile)
        
        [mix sr] = mixBubbleNoise(cleanFile, sr, useHoles, bubblesPerSec, snr, dur_s);
        
        ensureDirExists(outFile);
        wavwrite(mix, sr, outFile);
    end
end
