function root = bubbleDataRoot()

if ispc
    root = 'D:\Box Sync\data';
else
    root = '/home/data';
    if ~exist(root, 'file')
        root = '~/data';
    end
end