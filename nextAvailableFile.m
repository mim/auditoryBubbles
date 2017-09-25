function [outPath num outFile lastPath] = nextAvailableFile(outDir, pattern, args, num, ext)

% Find next available file that does not yet exist by incrementing a number
% in the file name.  Pattern should have args first, then num, and not
% include ext.  Ext should start with a dot (third argument of fileparts).

lastPath = '';
while true
    outFile = [sprintf(pattern, args{:}, num) ext];
    outPath = fullfile(outDir, outFile);
    if exist(outPath, 'file')
        lastPath = outPath;
    else
        break
    end 
    num = num + 1;
end
