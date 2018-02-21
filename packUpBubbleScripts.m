function files = packUpBubbleScripts()

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

packUp(dest, files, dataFiles, fnsThatShouldRun);
