function collectPcaFeatures(pcaDir, groupedFile, outDir, overwrite)

% Collect output of extractBubbleFeatures and match up with user results

if ~exist('overwrite', 'var') || isempty(overwrite), overwrite = false; end

load(groupedFile)  % should contain variable "grouped"
ansFile = strrep(grouped(:,3), '\', filesep);
ansFile = strrep(ansFile, '.wav', '.mat');
fracRight = grouped(:,5);

files = findFiles(pcaDir, '\d+.mat');

% Match files to ansFile to get fracRight
keep  = false(size(files));
match = zeros(size(files));
for f = 1:length(files)
    ind = find(strcmp(files{f}, ansFile));
    if length(ind) == 1
        keep(f)  = true;
        match(f) = ind;
    elseif length(ind) > 1
        error('Too many matches (%d) for %s', length(ind), files{f});
    end
end

assert(all(strcmp(files(keep), ansFile(match(keep)))))
files     = files(keep);
fracRight = fracRight(match(keep));

% Group by word, load PCA features
word  = regexprep(files, '\d+.mat', '');
[words,~,wi] = unique(word);
for w = 1:length(words)
    use = (wi == w);
    saveWordFile(words{w}, pcaDir, files(use), fracRight(use), outDir, overwrite)
end


function saveWordFile(word, inDir, files, fracRight, outDir, overwrite)

outFile = fullfile(outDir, [word '.mat']);
if exist(outFile, 'file') && ~overwrite
    return
end

for f = 1:length(files)
    tmp = load(fullfile(inDir, files{f}));
    pcaFeat(f,:) = tmp.pcaFeat';
end
fracRight = cell2mat(fracRight);

ensureDirExists(outFile)
save(outFile, 'pcaFeat', 'fracRight', 'files', 'inDir')
