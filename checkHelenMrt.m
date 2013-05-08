function checkHelenMrt

%dirs = listMap(@(x) ['Z:\data\mrt\helen\helenWords' x], {'01', '02', '03'});
dirs = listMap(@(x) ['Z:\data\mrt\helen\helenWordsPad' x], {'05', '02', '03'});

rhymeFile = 'Z:\data\mrt\helen\rhymesEdited.txt';
words = textread(rhymeFile, '%s');
words = reshape(words, 6, [])';

words = {'din', 'fin', 'pin', 'sin', 'tin', 'win'};

for r = 1:size(words,1)
    for c = 1:size(words,2)
        fprintf('%s', words{r,c})
        for d = 1:length(dirs)
            fileName = fullfile(dirs{d}, [words{r,c} '.wav']);
            if exist(fileName, 'file')
                fprintf('.')
                [x fs] = wavReadBetter(fileName);
                sound(x, fs);
            else
                fprintf('-');
            end
        end
        fprintf(' ')
    end
    fprintf('\n')
end