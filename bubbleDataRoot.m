function root = bubbleDataRoot()

if ispc
    root = 'Z:\data';
else
    root = '/home/data';
    if ~exist(root, 'file')
        root = '~/data';
    end
end