function status = extractFeatures(inDir, outDir, outExt, files, fn, nJobs, ...
    part, ignoreErrors, overwrite)

% General wrapper for extracting features from files
%
% extractFeatures(inDir, outDir, files, fn, nJobs, part, overwrite)
%
% fn has the following prototype:
%   fn(inPath, outPath, fileName);
%
% Where inPath is the full path to the input file, outPath is the
% full path to the output file (including the correct extension),
% and fileName is the path to the file not including inDir or
% outDir and not including an extension.
%
% part is a 2-vector, e.g. [3 4] meaning this is the third part out of
% four parts (starting at 1 for the first part).  This is in addition
% to running each part across nJobs workers through matlabpool, so
% using 4 parts and 8 workers would use 32 processors.
%
% Returned status is {-1,0,1} for each file.  -1 means that the file was
% not able to be processed (if ignoreErrors is true), 0 means that it was
% not processed, and 1 means that it was processed successfully.

% Copyright 2013 Michael Mandel - All Rights Reserved

if ~exist('nJobs', 'var') || isempty(nJobs), nJobs = 1; end
if ~exist('part', 'var') || isempty(part), part = [1 1]; end
if ~exist('overwrite', 'var') || isempty(overwrite), overwrite = false; end
if ~exist('ignoreErrors', 'var') || isempty(ignoreErrors), ignoreErrors = false; end

inds = part(1):part(2):length(files);
filesInds  = files(inds);
statusInds = zeros(size(inds));
status     = zeros(size(files));

allDone = true;
fileNames = cell(size(filesInds));
outPaths  = cell(size(filesInds));
for fi=1:length(filesInds)
    file = filesInds{fi};
    [subD subF] = fileparts(file);
    fileNames{fi} = fullfile(subD, subF);
    
    outPaths{fi} = fullfile(outDir, [fileNames{fi} '.' outExt]);
    allDone = allDone & exist(outPaths{fi}, 'file');
end
if allDone && ~overwrite, return, end

% if nJobs > 1
%     matlabpool('open', nJobs)
% end

%parfor fi = 1:length(inds)
for fi = 1:length(inds)
    file     = filesInds{fi};
    inPath   = fullfile(inDir, file);
    outPath  = outPaths{fi};
    fileName = fileNames{fi};
    fprintf('FE %d: %s\n', inds(fi), file)

    if exist(outPath, 'file') && ~overwrite
        fprintf('\b <--- Skipping\n');
        continue;
    end

    ensureDirExists(outPath)
    if ignoreErrors
        try
            fn(inPath, outPath, fileName)

            if exist(outPath, 'file')
                statusInds(fi) = 1;
            else
                fprintf('  ^^^ Failed: file not written ^^^\n');
                statusInds(fi) = -1;
            end
        catch err
            fprintf('  ^^^ Failed: %s ^^^\n', err.message);
            statusInds(fi) = -1;
        end
    else
        fn(inPath, outPath, fileName)
        statusInds(fi) = 1;

        if ~exist(outPath, 'file')
            error('File not written: %s', outPath)
        end
    end
end
status(inds) = statusInds;

% if nJobs > 1
%     matlabpool('close')
% end
