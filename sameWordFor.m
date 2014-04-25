function [inds words speakers uts diffWordInds] = sameWordFor(targetInd, fileNames, combineExps)
% Match words from stimuli names
%
% inds = sameWordFor(targetInd, fileNames, combineExps)
%
% Returns a list of indices into fileNames of the files that contain the
% same word and possibly the same speaker as the target.
%
% Inputs:
%   targetInd    index into fileNames of the target utterance
%   fileNames    cell array of file names of stimulus files
%   combineExps  if 1, return indices for all speakers of target stimulus,
%                otherwise, return indices only for speakers from the same
%                experiment (exp1 is w3, exp2 is w2, w4, w5)

[targetWord targetSpeaker] = extractWordAndSpeaker(fileNames{targetInd});

oneUtPerSpeaker = 0;
if combineExps
    matchingSpeakers = {'w2', 'w3', 'w4', 'w5'};
else
    if strcmp(targetSpeaker, 'w3')
        matchingSpeakers = {'w3'};
    else
        matchingSpeakers = {'w2', 'w3', 'w4', 'w5'};
        oneUtPerSpeaker = 1;
    end
end

inds = [];
for f = 1:length(fileNames)
    [words{f} spk{f} uts{f}] = extractWordAndSpeaker(fileNames{f});
    if strcmp(words{f}, targetWord) && any(strcmp(spk{f}, matchingSpeakers))
        inds(end+1) = f;
    end
end
if oneUtPerSpeaker
    [~,u] = unique(spk(inds));
    inds = inds(u);
end
diffWordInds = find(~strcmp(words, targetWord));

inds = [targetInd setdiff(inds, targetInd)];
words = words(inds);
speakers = spk(inds);


function [word speaker utName] = extractWordAndSpeaker(fileName)
try
    tokens = regexp(fileName, '(a\w+a)_(w\d)', 'tokens');
    word = tokens{1}{1};
    speaker = tokens{1}{2};
catch err
    tokens = regexp(fileName, '\\(\w+)_bps', 'tokens');
    word = tokens{1}{1};
    speaker = 1;
end
utName = basename(fileName, 0);
