function root = bubbleDataRoot()

candidates = {'D:\Box Sync\data', ...
              '/home/data/bubbles/orig/', ...
              '/home/data/mrt/', ...
              '~/data'};

for i = 1:length(candidates)
    if exist(candidates{i}, 'dir')
        root = candidates{i};
        return
    end
end
error('No candidate root was found')
