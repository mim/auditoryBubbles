function [h p isHigh] = tfCrossTab(cor0Pres0, cor0Pres1, cor1Pres0, cor1Pres1)

% Test whether co-occurrence of corect and present could happen by
% chance
%
% [h p isHigh] = tfCrossTab(cor0Pres0, cor0Pres1, cor1Pres0, cor1Pres1)
%
% Each argument is an FxT matrix of counts of how many times a
% particular TF point was present and how many of those times the
% mixture was correctly identified.
    
counts = cat(3, cor0Pres0, cor0Pres1, cor1Pres0, cor1Pres1);

expCor0 = cor0Pres0 + cor0Pres1;
expCor1 = cor1Pres0 + cor1Pres1;
expPres0 = cor0Pres0 + cor1Pres0;
expPres1 = cor0Pres1 + cor1Pres1;

expected = cat(3, expCor0.*expPres0, expCor0.*expPres1, ...
    expCor1.*expPres0, expCor1.*expPres1);
expected = bsxfun(@rdivide, expected, sum(counts,3));

[h p] = twoWayTableChi2(counts, expected);
isHigh = counts(:,:,4) > expected(:,:,4);

function [h p] = twoWayTableChi2(counts, expected)
% Parallel version of chi2gof for all TF points at once
alpha = 0.05;
minCount = 5;

cstat = sum((counts - expected).^2 ./ max(expected, 1e-4), 3);
p = chi2pval(max(cstat, 1e-4), 1);
p(any(expected <= minCount, 3)) = NaN;  % was "all", seems like it should be "any" for some reason
h = p < alpha;

function p = chi2pval(x,v)
p = gammainc(x/2,v/2,'upper');
