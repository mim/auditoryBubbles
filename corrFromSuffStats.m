function [C tstat pval vis mux muy stdx stdy] = corrFromSuffStats(n, x1, x2, y1, y2, xy)

% Compute correlation matrix from sufficient statistics
%
% [C tstat pval vis mux muy stdx stdy] = corrFromSuffStats(n, x1, x2, y1, y2, xy)
%
% Uses output of corrSufficientStats to compute the correlation, C.  Also
% computes the t-statistic for each entry, tstat, the p-value of those
% t-statistics for each entry, pval, and how to visualize them in a plot,
% vis.

mux = x1 / n;
muy = y1 / n;
varx = x2/n - mux.^2;
vary = y2/n - muy.^2;
stdx = sqrt(max(eps, varx));
stdy = sqrt(max(eps, vary));
Sx = spdiags(1./stdx', 0, length(mux), length(mux));
Sy = spdiags(1./stdy', 0, length(muy), length(muy));
C = single(full(Sx * double(xy/n - mux' * muy) * Sy));

tstat = C .* sqrt(max(0, (n - 2) ./ (1 - C.^2)));
pval  = tcdf(tstat, n - 2);
vis = exp(-(1-pval) / 0.025) - exp(-pval / 0.025);
