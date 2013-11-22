function pathInfoToTable(paths)

% Take paths with parameter settings and results and put them in a table
%
% Paths are of the form exp1/trim30/iov=0/doWarp=0/target=4/pcaDims=40,trI=2
% Replace exp1 and trim30 with exp=1 and trim=30. Split on / and ,
% Table is for org mode in emacs, keys become column headings, values
% become column values.
%
% Call like this:
% paths = findFiles('C:\Temp\plots\', 'pcaDims*'); keep=reMatch(paths, 'xval'); pathInfoToTable(paths(keep));
% paths = findFiles('C:\Temp\plots\', 'pcaDims*'); keep=reMatch(paths, 'trainSvm'); pathInfoToTable(paths(keep));

% Convert paths to struct array, ensure matching fields
for p = 1:length(paths)
    fields = split(regexprep(paths{p}, '=?(\d+)(/|\\)', '=$1/'), ',|/|\\');
    for f = 1:length(fields)
        kv = split(fields{f}, '=');
        strTmp.(kv{1}) = kv{2};
    end
    str(p) = orderfields(strTmp);
end

% Convert struct array to org table
fields = fieldnames(str);
fprintf('| %s |\n', join(fields, ' | '));
for p = 1:length(str)
    fprintf('| %s |\n', join(struct2cell(str(p)), ' | '));
end
