function struct2org(str)

% Print out an emacs org-mode table from structure array str

% Convert struct array to org table
fields = fieldnames(str);
fprintf('| %s |\n', join(fields, ' | '));
for p = 1:length(str)
    fprintf('| %s |\n', join(struct2cell(str(p)), ' | '));
end
