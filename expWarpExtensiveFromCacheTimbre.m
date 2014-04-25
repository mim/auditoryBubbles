function expWarpExtensiveFromCacheTimbre(pcaDims)

% Run lots of experiments on warped bubble noise data

if ~exist('pcaDims', 'var') || isempty(pcaDims), pcaDims = 24; end

outDir  = 'C:\Temp\data\timbre\v1\expWarpOut';
inDir   = 'C:\Temp\data\timbre\v1\expWarpCache';

doWarps = 0;
targets = 1:7;

runFunctions = {
    'xvalSvmOnEachWord', ...
};

expWarpExtensiveFromCache(outDir, inDir, runFunctions, doWarps, targets, pcaDims);
