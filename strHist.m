function [h uStrs] = strHist(strs, uStrs)

% Compute a histogram of strings
%
% [h uStrs] = strHist(strs, [uStrs])


if ~exist('uStrs', 'var') || isempty(uStrs), uStrs = unique(strs); end

if ~isempty(setdiff(unique(strs), uStrs))
    warning('Some strings not included in list')
end

h = zeros(length(uStrs), 1);
for i = 1:length(uStrs)
    h(i) = sum(strcmp(uStrs{i}, strs));
end
