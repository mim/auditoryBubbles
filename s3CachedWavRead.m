function [x fs] = s3CachedWavRead(url, force)

% Read a wav from an Amazon S3 URL or a local cache
%
% [x fs] = s3CachedWavRead(url, force)
%
% If force is true, then re-download the file even if it's already cached.

if ~exist('force', 'var') || isempty(force), force = false; end
cacheRoot = 'D:\scratch\s3cache';

cacheFile = fullfile(cacheRoot, regexprep(url, 'https?://', ''));
if ~exist(cacheFile, 'file') || force
    % fprintf('Downloading...\n');
    ensureDirExists(cacheFile);
    urlwrite(url, cacheFile);
else
    % fprintf('Already have it\n');
end
[x fs] = wavReadBetter(cacheFile);
