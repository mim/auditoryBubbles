function outRows = unpackMTurkCsv(inFile, outFile)

% Parse an MTurk csv file with multiple sounds per HIT into a CSV file with
% one sound per row.  Hard coded to work with 5 URLs per HIT.

if ~exist('outFile', 'var'), outFile = ''; end

fields = {'WorkerId', 'RejectionTime', ...  these will go in every row
    'Input.url1', 'Answer.wordchoice1', ...  these will each have their own row
    'Input.url2', 'Answer.wordchoice2', ...
    'Input.url3', 'Answer.wordchoice3', ...
    'Input.url4', 'Answer.wordchoice4', ...
    'Input.url5', 'Answer.wordchoice5'};
commonFields = 2;

C = csvReadCells(inFile);
headers = C(1,:);
data = C(2:end,:);

% Find fields in C
for f = 1:length(fields)
    fieldNum(f) = strmatch(fields{f}, headers);
end

% Get all rows for each set of columns
outArray = {};
for f = commonFields+1:2:11
    newOutRows = [data(:,fieldNum(1:commonFields)) data(:,fieldNum(f:f+1))];
    outArray = [outArray; newOutRows];
end
%outArray = [headers(fieldNum(1:4)); outArray];

% Convert 2D cell array into an array of arrays
outRows = cell(size(outArray,1), 1);
for r = 1:size(outArray,1)
    outRows{r} = outArray(r,:);
end

% % Get rid of rows with blank fields
% keepRows = cellfun(@(x) all(cellfun(@(y) ~isempty(y), x)), outRows);
% outRows = outRows(keepRows);

% Write
if ~isempty(outFile)
    csvWriteCells(outFile, outRows, 'a');
end
