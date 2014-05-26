function expWarpExtensiveFromCacheShannon(expNum, trimDir, pcaDims)

% Run lots of experiments on warped bubble noise data

if ~exist('pcaDims', 'var') || isempty(pcaDims), pcaDims = 70; end
if ~exist('trimDir', 'var') || isempty(trimDir), trimDir = 'trim=30,length=2.2'; end
if ~exist('expNum', 'var') || isempty(expNum), expNum = 12; end

expDir  = sprintf('exp%d', expNum); 
outDir  = fullfile('C:\Temp\data\resultsPbcBalTr', expDir, trimDir);
inDir   = fullfile('C:\Temp\data\tfctAndPcaPbc', expDir, trimDir);
pcaStructFile = 'C:\Temp\mrtFeatures\shannonLight\exp12\trim=30,length=2.2\pcaData_100dims_1000files.mat';

doWarps = [1 0];
targets = [5:6:36 2:6:36];
runFunctions = {
    'trainSvmOnOne', ...
    'trainSvmOnAllButOne', ...
    'trainSvmOnAllButOneLimNtr', ...
    'xvalSvmOnEachWord', ...
    'xvalSvmOnPooled', ...
    'visSvmOnOne' ...
};

expWarpExtensiveFromCache(outDir, inDir, pcaStructFile, runFunctions, doWarps, targets, pcaDims);
