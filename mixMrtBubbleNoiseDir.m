function outDir = mixMrtBubbleNoiseDir(inDir, outDir, nMixes, bubblesPerSec, snr_db, dur_s, normalize, noiseShape, speechFiles)

% Generate mixtures of bubble noise with clean files from a directory
%
% mixMrtBubbleNoiseDir(inDir, outDir, nMixes, bubblesPerSec, snr_db, dur_s, normalize, noiseShape, speechFiles)
%
% Mixture files will have the same name as the original files with a
% mixture number appended.  It is safe to run this function multiple times
% with the same arguments, it will only create new mixtures if there are
% not enough in outDir already.
%
% Inputs:
%   inDir         directory in which to find clean input files
%   outDir        directory in which to write wav file for each mixture.
%                 Files will be written in a subdirectory named "bpsNN"
%                 where NN is the bubbles-per-second value.
%   nMixes        maximum number of mixes per clean file, if some mixes
%                 already exist, enough will be added to reach this many
%   bublesPerSec  number of bubbles in noise per second of mix file
%   snr_db        scaling parameter for the clean files, in dB from an RMS of 0.1
%   dur_s         desired duration of mix files, clean files will be
%                 zero-padded or truncated from both ends to be this length
%   normalize     normalize each clean file to have an RMS of 0.1 before scaling
%   noiseShape    numeric specifier of noise shape passed to speechProfile()
%   speechFiles   list of files (relative to inDir) or regexp of files to
%                 find in inDir to use as clean files. If blank, use all

if ~exist('bubblesPerSec', 'var') || isempty(bubblesPerSec), bubblesPerSec = 15; end
if ~exist('snr_db', 'var') || isempty(snr_db), snr_db = -30; end
if ~exist('nMixes', 'var') || isempty(nMixes), nMixes = 1; end
if ~exist('dur_s', 'var') || isempty(dur_s), dur_s = 2; end
if ~exist('normalize', 'var') || isempty(normalize), normalize = 1; end
if ~exist('noiseShape', 'var') || isempty(noiseShape), noiseShape = 0; end
if ~exist('speechFiles', 'var') || isempty(speechFiles), speechFiles = findFiles(inDir, '\.wav'); end

outDir = fullfile(outDir, sprintf('bps%g', bubblesPerSecond));

if ischar(speechFiles)  % Can supply a pattern
    speechFiles = findFiles(inDir, speechFiles, 1);
end

useHoles = true;
snr = db2mag(snr_db);

for i = 1:length(speechFiles)
    cleanFile = fullfile(inDir, speechFiles{i});
    [~,sr] = wavread(cleanFile);
    
    num = -1;
    while true
        [d f e] = fileparts(speechFiles{i});

        % Find next available file name
        numTaken = true;
        while numTaken
            num = num + 1;
            %outFile = fullfile(outDir, sprintf('bps%g', bubblesPerSec), ...
            %    sprintf('snr%+d', snr_db), d, sprintf('%s_%03d%s', f, num, e));
            outFile = fullfile(outDir, d, sprintf('%s_bps%g_snr%+d_%03d%s', ...
                f, bubblesPerSec, snr_db, num, e));
            numTaken = exist(outFile, 'file');
        end
        if num >= nMixes
            break
        end
        fprintf('%d %d: %s\n', i, num, outFile)
        
        [mix sr] = mixBubbleNoise(cleanFile, sr, useHoles, bubblesPerSec, snr, dur_s, normalize, noiseShape);
        
        ensureDirExists(outFile);
        wavwrite(mix, sr, outFile);
    end
end
