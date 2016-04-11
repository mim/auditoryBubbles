function it = infoTransmit(confMat, groups)

% Miller and Nicely's information transmission for a confusion matrix
%
% it = infoTransmit(confMat, [groups])
%
% Compute Miller and Nicely's information transmission on a confusion
% matrix with some of the entries potentially grouped together.  The
% confusion matrix should have rows corresponding to ground truth
% categories.

if ~exist('groups', 'var') || isempty(groups), groups = 1:size(confMat,1); end

% Convert groups into numbers (could start as strings)
[~,~,groups] = unique(groups);

% Group matrix entries (should be able to do this with a matrix
% multiply...)
groupedConfMat = zeros(max(groups));
for g1 = 1:size(groupedConfMat)
    i1 = (groups == g1);
    for g2 = 1:size(groupedConfMat)
        i2 = (groups == g2);
        groupedConfMat(g1, g2) = sum(sum(confMat(i1, i2)));
    end
end

ni = sum(groupedConfMat,2);
nj = sum(groupedConfMat,1);
n  = sum(groupedConfMat(:));

pi = ni ./ n;
pj = nj ./ n;
pij = groupedConfMat ./ n;

T = -sum(sum(pij .* log((pi * pj) ./ (pij+eps))/log(2)));
H = -sum(pi .* log(pi)/log(2));

it = T ./ H;
