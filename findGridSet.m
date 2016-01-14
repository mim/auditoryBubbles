function strs = findGridSet(X)

% Find set of GRID utterances that are close to the cross product of different sets

% X = textArray('Z:/train_allids.list'); 
% X = regexprep(X, 'id(./)', 'id0$1'); 
% X = strvcat(X);

% Group by speaker and filler words
[a b c] = unique(cellstr(X(:,[3 4 6 8 11]))); 
[d e] = hist(c, 1:max(c));

for i = 1:length(e)
    % Compute groups with doubled letters (pos 9)
    inds = find(c == e(i));
    strs = X(inds,:);

    [a2 b2 c2] = unique(cellstr(strs(:,9)));
    [d2 e2] = hist(c2, 1:max(c2));
    dupLetters(i) = sum(d2 > 1);
end

[~,ord] = sort(-dupLetters);
inds = find(c == e(ord(1)));
strs = X(inds,:);
