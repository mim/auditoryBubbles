function files = packUp

% Copy necessary files into a dist directory and test that everything works
% with the path cleared.

dest = 'D:\My Box Files\bubblesShannon\code\';

files = {
    'playListeningTestDir.m'
    'csvWriteCells.m'
    'playCalibrationFile.m'
    'Z:\code\matlab\listMap.m'
    'Z:\code\matlab\findFiles.m'
    'Z:\code\matlab\reMatch.m'
    'Z:\code\matlab\split.m'
    'Z:\code\matlab\ensureDirExists.m'
    'Z:\code\matlab\join.m'
    'Z:\code\matlab\wavReadBetter.m'
    };

dataFiles = {
    };

fnsThatShouldRun = {@() playListeningTestDir('D:\mixes\shannon\sorted\forTesting', 'packUp')};

ensureDirExists(dest);
rmdir(dest, 's');
ensureDirExists(dest);

disp('Copying files over')
for f = 1:length(files)
    copyfile(files{f}, dest);
end
for f = 1:length(dataFiles)
    fileDest = fullfile(dest, dataFiles{f});
    ensureDirExists(fileDest);
    copyfile(dataFiles{f}, fileDest);
end

disp('Remembering current state')
origDir = pwd();
origPath = path();
rmFromPath = findMatlabDirs();

keepGoing = true;
missingFile = '';
while keepGoing
    disp('Clearing state')
    rmpath(rmFromPath{:});
    cd(dest);

    disp('Testing')
    try
        for f = 1:length(fnsThatShouldRun)
            fnsThatShouldRun{f}();
        end
        keepGoing = false;
    catch e
        fprintf('Error: %s\n', e.message)
        if strcmp(e.identifier, 'MATLAB:UndefinedFunction')
            missingFile = regexprep(e.message, '^.*?''(.*?)''.*$', '$1');
        else
            keepGoing = false;
        end
    end

    disp('Restoring original state')
    cd(origDir);
    path(origPath);
    
    if ~isempty(missingFile)
        mf = which(missingFile);
        files{end+1} = mf;
        fprintf('missing file: ''%s''\n', mf);
        copyfile(mf, dest)
    end
end
