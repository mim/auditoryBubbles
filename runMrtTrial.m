function [picked paths correct] = runMrtTrial(wavDir, wordSetListFile, nTrials)

% Play random MRT examples for the user, give possible choices, get
% response, return vector indicating which trials were correct and what the
% confusions were.

[wavFileNames wavFilePaths] = findFiles(wavDir, '\.wav');
words = textread(wordSetListFile, '%s');
words = reshape(words, 6, [])';

picked = {};
paths = {};
for i = 1:nTrials
    s = ceil(rand(1) * size(words,1));
    w = ceil(rand(1) * size(words,2));    
    word = words{s, w};
    
    ind = strmatch(word, wavFileNames);
    r = ceil(rand(1) * length(ind));
    wavFile = wavFilePaths{ind(r)};
    paths{i} = wavFile;
    
    ord = randperm(size(words,2));
    for opt = 1:size(words,2);
        fprintf('%d:% 7s    ', opt, words{s, ord(opt)});
    end
    fprintf('\n')
    [x fs] = wavread(wavFile);
    sound(x, fs);

    choice = input('Which word did you hear? ');
    picked{i} = words{s, ord(choice)};
    correct(i) = ord(choice) == w;
end
