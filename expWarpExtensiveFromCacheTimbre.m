function expWarpExtensiveFromCacheTimbre(groupedName, pcaDims)

% Run lots of experiments on warped bubble noise data

if ~exist('groupedName', 'var') || isempty(groupedName), groupedName = 'mim100'; end
if ~exist('pcaDims', 'var') || isempty(pcaDims), pcaDims = 24; end

outDir  = fullfile('C:\Temp\data\timbre\v1', groupedName, 'expWarpOut');
inDir   = fullfile('C:\Temp\data\timbre\v1', groupedName, 'expWarpCache');

doWarps = 0;
targets = 1:7;

runFunctions = {
    'xvalSvmOnEachWord', ...
};

expWarpExtensiveFromCache(outDir, inDir, runFunctions, doWarps, targets, pcaDims);
