function [picked paths correct] = runMrtTrial(wavDir, wordSetListFile, nTrials)

% Play random MRT examples for the user, give possible choices, get
% response, return vector indicating which trials were correct and what the
% confusions were.

if ~exist('wordSetListFile', 'var') || isempty(wordSetListFile), wordSetListFile = 'Z:\data\mrt\rhymesEdited.txt'; end
if ~exist('nTrials', 'var') || isempty(nTrials), nTrials = 20; end

resFile = 'Z:\data\mrt\results.csv';

[wavFileNames wavFilePaths] = findFiles(wavDir, '\.wav');
words = textread(wordSetListFile, '%s');
words = reshape(words, 6, [])';

picked = {};
paths = {};
ws = ceil(rand(1, nTrials) * size(words, 2));
for i = 1:nTrials
    %s = ceil(rand(1) * size(words,1));
    s = 8;
    w = ws(i);
    word = words{s, w};
    
    ind = strmatch(word, wavFileNames);
    r = ceil(rand(1) * length(ind));
    wavFile = wavFilePaths{ind(r)};
    paths{i} = wavFile;

    % Print prompt
    fprintf('\n')
    ord = randperm(size(words,2));
    for opt = 1:size(words,2);
        fprintf('%d: %-7s  ', opt, words{s, ord(opt)});
    end
    fprintf('\n')
    tic;
    
    % Play file
    [x fs] = wavread(wavFile);
    sound(x, fs);
    setupTime = toc;
    
    % Get input robustly
    while true
        try
            choice = input('Which word did you hear? ');
            picked{i} = words{s, ord(choice)};
            correct(i) = ord(choice) == w;
            break
        catch err
            % Don't do anything, just keep looping
        end
    end
    answerTime = toc;
    
    if correct(i)
        fprintf('Correct!\n');
    else
        fprintf('Incorrect: you chose %s, was %s\n', picked{i}, word);
    end
    
    f = fopen(resFile, 'a');
    fprintf(f, '%s\t%s\t%s\t%d\t%g\t%g\n', paths{i}, word, picked{i}, ...
        correct(i), setupTime, answerTime);
    fclose(f);
end
