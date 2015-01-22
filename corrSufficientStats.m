function [n x1 x2 y1 y2 xy] = corrSufficientStats(x, y)

% Compute sufficient statistics for the correlation between x and y
%
% [n x1 x2 y1 y2 xy] = corrSufficientStats(x, y)
%
% Each row of x and y is assumed to be an observation.  Thus, they must
% have the same number of rows, but could have different numbers of
% columns.

assert(size(x,1) == size(y,1));
n = size(x,1);
x1 = single(sum(x,1));
x2 = single(sum(x.^2,1));
y1 = single(sum(y,1));
y2 = single(sum(y.^2,1));
xy = single(x' * y);
