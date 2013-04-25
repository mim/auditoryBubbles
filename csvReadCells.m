function C = csvReadCells(fileName)

% Read text data from a comma-separated variables file
%
% C = csvReadCells(fileName)
% 
% Data in the file should be comma-separated and enclosed in quotes.
% Escaped quotes in the middle of fields will be unescaped.  C is a 2D cell
% array.

text = fileread(fileName);
lines = split(text, '\n');
nonEmpty = cellfun(@(x) ~isempty(x), lines);
lines = lines(nonEmpty);

for i = 1:length(lines)
    line = regexprep(regexprep(lines{i}, '"\s*$', ''), '^"', '');
    fields = strrep(split(line, '","'), '\"', '"');
    caOfCas{i} = fields;
end

maxLen = max(cellfun(@length, caOfCas));
for i = 1:length(caOfCas)
    if length(caOfCas{i}) < maxLen
        caOfCas{i}{maxLen} = '';
    end
end

C = cat(1, caOfCas{:});
