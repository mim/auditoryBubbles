function [pcs coefs] = pca(X)
    
% Principal components analysis of matrix X
%
% [pcs coefs] = pca(X)
%
% Columns of X should have zero mean.  The principal components
% satisfy: coefs * pcs' = X and pcs' * pcs = I.  If X is MxN,
% and D = min(M,N), then coefs is MxD and pcs is NxD.

[U S V] = svd(X, 'econ');
pcs = V;
coefs = U * S;
