function [vals correct paths picked] = findMrtBubbleNoiseParams(...
    inDir, wordSetListFile, tuneBps, bubblesPerSec, snr_dB, dur_s)

% Adaptively set SNR or bubblesPerSec for mixtures generated on the fly
% until the user gets 50% correct.

if ~exist('inDir', 'var') || isempty(inDir), inDir = 'Z:\data\mrt\helenWords01'; end
if ~exist('wordSetListFile', 'var') || isempty(wordSetListFile), wordSetListFile = 'Z:\data\mrt\rhymesEdited.txt'; end
if ~exist('tuneBps', 'var') || isempty(tuneBps), tuneBps = false; end
if ~exist('bubblesPerSec', 'var') || isempty(bubblesPerSec), bubblesPerSec = 15; end
if ~exist('snr_dB', 'var') || isempty(snr_dB), snr_dB = -30; end
if ~exist('dur_s', 'var') || isempty(dur_s), dur_s = 2; end

maxIter = 50;
inARow = 3;
stopHist = 7;
useHoles = true;
targetSr = 8000;

% Figure out arguments to makeMix based on which variable is being tuned
if tuneBps
    beforeArgs = {};
    curVal = bubblesPerSec;
    afterArgs = {10^(snr_dB/20), dur_s};
    if useHoles
        harderFrac = 0.9;
    else
        harderFrac = 1.1;
    end
else
    beforeArgs = {bubblesPerSec};
    curVal = 10^(snr_dB/20);
    afterArgs = {dur_s};
    harderFrac = 0.9;
end

[wavFileNames wavFilePaths] = findFiles(inDir, '\.wav');
words = textread(wordSetListFile, '%s');
words = reshape(words, 6, [])';

vals = [];
correct = [];
picked = {};
paths = {};
waitToAdapt = 0;
for i = 1:maxIter
    vals(i) = curVal;
    
    while true
        %s = ceil(rand(1) * size(words,1));
        s = 8;
        w = ceil(rand(1) * size(words,2));
        word = words{s, w};
        ind = strmatch(word, wavFileNames);

        if length(words(s,:)) ~= length(unique(words(s,:)))
            warning('mrtbnp:duplicate', 'Duplicate word found: %s', word)
        else
            break
        end
    end
    wavFile = wavFilePaths{ind(1)};
    paths{i} = wavFile;
    
    % Make mixture
    [mix sr] = mixBubbleNoise(wavFile, targetSr, useHoles, beforeArgs{:}, curVal, afterArgs{:});
    
    % Print prompt
    fprintf('\n')
    ord = randperm(size(words,2));
    for opt = 1:size(words,2);
        fprintf('%d: %-7s  ', opt, words{s, ord(opt)});
    end
    fprintf('\n')

    % Play mixture
    sound(mix, sr);

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

    if correct(i)
        fprintf('Correct!\n');
    else
        fprintf('Incorrect: you chose %s, was %s\n', picked{i}, word);
    end
    
    % Update parameters
    if (waitToAdapt <= 0) && (length(correct) >= inARow) ...
            && all(correct(i-inARow+1:i) == correct(i))
        curVal = curVal * harderFrac.^(2*correct(i)-1);
        fprintf('\b   newVal: %g\n', curVal);
        waitToAdapt = inARow;
    end
    waitToAdapt = waitToAdapt - 1;
    
    % Figure out whether to stop
    if length(correct) >= stopHist
        lastCorrect = mean(correct(i-stopHist+1:i));
        % This should really use a binomial model with a significance level
        if (stopHist/2-1 <= lastCorrect) && (lastCorrect <= stopHist/2+1)
            break
        end
    end
end
