function [isRight fracRight files] = isRightFor(files, groupedFile)

% Return supervision label for each file in files by looking it up in
% groupedFile, the output of groupBy()

load(groupedFile)  % should contain variable "grouped"
ansFile = strrep(grouped(:,3), '\', filesep);
ansFile = strrep(ansFile, '.wav', '.mat');
fracRight = grouped(:,5);

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

if ~all(keep)
    warning('Only keeping %d of %d files', sum(keep), length(keep));
    %assert(all(keep))
end
assert(all(strcmp(files(keep), ansFile(match(keep)))))
files     = files(keep);
fracRight = cell2mat(fracRight(match(keep)));
isRight   = (fracRight >= 0.9) - (fracRight <= 0.6);

