function grouped = digestMTurk(outFile, csvRe, wavRe, overwrite)

if ~exist('outFile', 'var'), outFile = ''; end
if ~exist('csvRe', 'var') || isempty(csvRe), csvRe = 'mim_.*'; end
if ~exist('wavRe', 'var') || isempty(wavRe), wavRe = 'helenWordsPad02.*\d+\.wav'; end
if ~exist('overwrite', 'var') || isempty(overwrite), overwrite = false; end

%[~,files] = findFiles('Z:\data\mrt\mturk_csv_out', csvRe, 1);
[~,files] = findFiles('/home/data/mrt/mturk_csv_out', csvRe, 1);

%digestFile = 'z:/data/mrt/mturk_csv_out/digested.csv'; 
digestFile = '/home/data/mrt/mturk_csv_out/digested.csv'; 
if exist(digestFile, 'file')
    delete(digestFile); 
end
for f=1:length(files), 
    unpackMTurkCsv(files{f}, digestFile); 
end
digested = csvReadCells(digestFile);

for i=1:size(digested,1), 
    [~,f] = fileparts(digested{i,3});
    if isempty(digested{i,4})
        digested{i,5} = 0;
    else
        digested{i,5} = strncmp(f, digested{i,4}, length(digested{i,4}));
    end
end

keep = reMatch(digested(:,3), wavRe) & cellfun(@isempty, digested(:,2));
grouped = groupBy(digested(keep,:), 3, @(x) basename(x,1,1), 3, @(x) mean([x{:}]), 5);

if isempty(outFile)
    return
end

%outPath = fullfile('Z:\data\mrt\mturk_results', outFile);
outPath = fullfile('/home/data/mrt/mturk_results', outFile);
if (exist(outPath, 'file') || exist([outPath '.mat'], 'file')) && ~overwrite
    fprintf('Not overwriting existing file: %s\n', outPath)
else
    save(outPath, 'grouped')
    fprintf('Wrote %d rows to %s\n', size(grouped,1), outPath)
end
