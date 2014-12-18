function [outPath num outFile] = nextAvailableFile(outDir, pattern, args, num, ext)

% Find next available file that does not yet exist by incrementing a number
% in the file name.  Pattern should have args first, then num, and not
% include ext.  Ext should start with a dot (third argument of fileparts).

numTaken = true;
while numTaken
    num = num + 1;
    outFile = [sprintf(pattern, args{:}, num) ext];
    outPath = fullfile(outDir, outFile);
    numTaken = exist(outPath, 'file');
end
