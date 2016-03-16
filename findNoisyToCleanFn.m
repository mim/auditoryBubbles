function noisyToCleanFn = findNoisyToCleanFn(noisyPath)
% Functions to map noisy paths to clean paths.  The system will try each of
% these in turn and pick the first one that leads to an existing file. Need
% to add the function pointer to the cell array tryFns in
% findNoisyToCleanFn below. 

% Add new functions to this cell array:
tryFns = { 
    @mapBubblePathToCleanPath
    @mapAdaptiveBubblePathToCleanPath
    @mapNoisyRemixPathToCleanPath
    @mapNoisyAsrPathToCleanPath
    };

noisyToCleanFn = [];
for n = 1:length(tryFns)
    cleanFile = tryFns{n}(noisyPath);
    if ~strcmp(noisyPath, cleanFile) && exist(cleanFile, 'file')
        noisyToCleanFn = tryFns{n};
        break;
    end
end
if isempty(noisyToCleanFn)
    error('No working noisy-to-clean function found (perhaps you haven''t generated bpsInf files?)');
else
    fprintf('Using noisyToCleanFn %d/%d: %s\n', n, length(tryFns), func2str(noisyToCleanFn));
end


function cleanPath = mapBubblePathToCleanPath(bubblePath)
cleanPath = regexprep(regexprep(bubblePath, 'bps[^_/\\]*', 'bpsInf'), '\d+\.([a-zA-Z]+)$', '000.$1');

function cleanPath = mapAdaptiveBubblePathToCleanPath(bubblePath)
mixDir = [filesep 'mix' filesep];
cleanDir = [filesep 'clean' filesep];
cleanPath = regexprep(regexprep(bubblePath, mixDir, cleanDir), '\d+\.([a-zA-Z]+)$', '.$1');

function cleanPath = mapNoisyAsrPathToCleanPath(noisyAsrPath)
cleanPath = regexprep(noisyAsrPath, 'noisy', 'clean');

function cleanPath = mapNoisyRemixPathToCleanPath(noisyRemixPath)
% Replace 'noisy' with 'cleanFiles', remove several directories at the end
% (that specify the noise instance).

parts = split(strrep(noisyRemixPath, 'noisy', 'cleanFiles'), filesep);
parts(end-4:end-2) = [];
cleanPath = join(parts, filesep);
1+1;
