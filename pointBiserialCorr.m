function [pbc pval vis] = pointBiserialCorr(s0, s1, n0, n1, sig)

% Compute the point-biserial correlation from summary statistics
%
% [pbc pval] = pointBiserialCorr(s0, s1, n0, n1, sig)
%
% Each row of s0, s1, and sig is analyzed separately. Also computes the
% p-value of a t-test using a transformation of the point biserial
% correlation coefficient, which should have n0+n1-2 degrees of freedom.
%
% Inputs:
%   s0, s1  (WxD) sum of continuous features for dichotomous values 0, 1
%   n0, n1  (Wx1) number of observations of dichotomous class 0, 1
%   sig     (WxD) standard deviation of all observations
%
% Outputs: 
%   pbc     (WxD) point biserial correlation coefficient
%   pval    (WxD) p-value for T-test on pbc value
%   vis     (WxD) visualization of two-tailed pval relative to 0.025
%
% See: http://en.wikipedia.org/wiki/Point-biserial_correlation_coefficient

n = n0 + n1;
pbc   = zeros(size(s0));
tstat = zeros(size(s0));
pval  = zeros(size(s0));

for w = 1:size(s0,1)
    pbc(w,:)   = (s1(w,:)/n1(w) - s0(w,:)/n0(w)) ./ sig(w,:) .* sqrt(n0(w)*n1(w) / n(w)^2);
    tstat(w,:) = pbc(w,:) .* sqrt((n(w) - 2) ./ (1 - pbc(w,:).^2));
    pval(w,:)  = tcdf(tstat(w,:), n(w) - 2);
end
vis = exp(-(1-pval) / 0.025) - exp(-pval / 0.025);
