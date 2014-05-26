function processListeningData(inCsvFile, outGroupedFile, verbose, unpackFn, append)

% Convert listening test file into the form extractTfctAndPca expects

if ~exist('unpackFn', 'var') || isempty(unpackFn), unpackFn = @unpackShsCsv; end
if ~exist('append', 'var') || isempty(append), append = 1; end
if ~exist('verbose', 'var') || isempty(verbose), verbose = 1; end

digestedFile = tempname;
unpackFn(inCsvFile, digestedFile);
digested = csvReadCells(digestedFile);
for i=1:size(digested,1)
    [~,f] = fileparts(digested{i,3}); 
    if isempty(digested{i,4})
        digested{i,5} = 0; 
    else
        digested{i,5} = strncmp(f, digested{i,4}, length(digested{i,4})); 
    end
    digested{i,6} = regexprep(basename(digested{i,3}), '_.*', ''); 
end
grouped = groupBy(digested, 3, @(x) basename(x,1), 3, @(x) mean([x{:}]), 5);
save(outGroupedFile, 'grouped', 'digested');

if verbose
    grouped2 = groupBy(digested, 6, @(x) mean([x{:}]), 5);
    fprintf('Avg:\t%0.1f%% correct\n', 100*mean([grouped{:,5}]));
    for i = 1:size(grouped2,1)
        fprintf('%s:\t%0.1f%% correct\n', grouped2{i,6}, 100*grouped2{i,5});
    end
end
