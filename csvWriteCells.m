function csvWriteCells(fileName, lines, writeMode)

% Write a comma-separate-variables file from a cell array of cell arrays
%
% csvWriteCells(fileName, lines, [writeMode])
%
% lines is a cell array of cell arrays, where each cell in the inner cell
% array will be one field in the CSV file.  All fields will be surrounded
% by double quotes and all double quotes in fields will be
% backslash-escaped.

if ~exist('writeMode', 'var') || isempty(writeMode), writeMode = 'w'; end

ensureDirExists(fileName)
f = fopen(fileName, writeMode);
for i = 1:length(lines)
    fprintf(f, '"%s"\n', join(strrep(lines{i}, '"', '\"'), '","'));
end
fclose(f);
fprintf('Wrote CSV to "%s"\n', fileName)
