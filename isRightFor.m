function [isRight fracRight files responseCounts equivClasses] = isRightFor(files, groupedFile)

% Return supervision label for each file in files by looking it up in
% groupedFile, the output of groupBy()

load(groupedFile, 'grouped', 'equivClasses', 'responseCounts');
ansFile = strrep(grouped(:,3), '\', filesep);
ansFile = regexprep(ansFile, '.wav$', '.mat');
if size(grouped,2) >= 7
    % New way, compute isRight in processListeningTest
    fracRight = cell2mat(grouped(:,5));
    isRight = cell2mat(grouped(:,7));
else
    % Old way, compute isRight here
    fracRight = cell2mat(grouped(:,5));
    isRight = (fracRight >= 0.9) - (fracRight <= 0.6);
end
    
% Match files to ansFile to get fracRight
keep  = false(size(files));
match = zeros(size(files));
for f = 1:length(files)
    ind = find(reMatch(ansFile, sprintf('(^|/|\\\\)%s$', files{f})));
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
% % replace with ends-with assertion...
%assert(all(strcmp(files(keep), ansFile(match(keep)))))
files     = files(keep);
fracRight = fracRight(match(keep));
isRight   = isRight(match(keep));
responseCounts = responseCounts(match(keep),:);