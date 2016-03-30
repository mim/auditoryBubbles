function processAsrData(noisyLines, gtLines, noisyIdToFileMap, modelName, outResultDir, noisyToCleanFn)

% Like processListeningData, but for ASR results, saves several results mat files
%
%   processAsrData(noisyLines, gtLines, noisyIdToFileMap, modelName, outResultDir)
%
% This function is meant to be wrapped by another function that loads the
% files to run it on, like processAsrDataWsj.  
%
% The current function takes a cell array of strings from the noisy
% transcripts and the ground truths loaded using textArray(), a structure
% mapping from noisyId that was created by makeIdToFileMap(), and a
% directory in which to write the output results files.
%
% Output files can then be read with mainBubbleAnalysis(). Each result file
% is an Nx6 cell array with fields: 
%   model, [blank], noisyFile, guess, isCorrect, rightAnswer

assert(length(gtLines) == length(noisyLines))

if isempty(gtLines{end})
  % Remove trailing empty line...
  gtLines = gtLines(1:end-1);
  noisyLines = noisyLines(1:end-1);
end

for i = 1:length(noisyLines)
    [cleanIds{i} noisyIds{i} gtWords{i} correctness{i} noisyWords{i}] = compareLine(gtLines{i}, noisyLines{i}, noisyToCleanFn);
end

printSentenceConfusions(gtWords, noisyWords);

% Create one results file per cleanId and word (and lwt)
[cleanIdList,~,cleanGroup] = unique(cleanIds);
for c = 1:length(cleanIdList)
    printStatus('.');
    cleanId = cleanIdList{c};
    groupIdx = find(cleanGroup == c);
    %printStatus(sprintf('%g ', mean([correctness{groupIdx}])))
    
    % Get words and make sure they're the same for all files with the
    % same clean id
    gtWordsNow = gtWords{groupIdx(1)};
    for g = 2:length(groupIdx)
        assert(all(strcmp(gtWords{groupIdx(g)}, gtWordsNow)));
    end    
    
    % Sentence-level correctness
    resultFile = sprintf('model=%s_clean=%s.mat', modelName, cleanId);
    resultPath = fullfile(outResultDir, modelName, resultFile);    
    tCor = cellfun(@all, correctness(groupIdx));
    createResultFile(resultPath, noisyIdToFileMap, noisyIds(groupIdx), tCor, modelName, cleanId, cleanIdList, cleanId);

    printScoredWords(gtWordsNow, mean(cat(1, correctness{groupIdx})), mean(tCor))
    
    % Correctness for each word
    for w = 1:length(gtWordsNow)
        resultFile = sprintf('model=%s_clean=%s_%02d_%s.mat', modelName, cleanId, w, gtWordsNow{w});
        resultPath = fullfile(outResultDir, modelName, resultFile);
        tCor = cellfun(@(x) x(w), correctness(groupIdx));
        createResultFile(resultPath, noisyIdToFileMap, noisyIds(groupIdx), tCor, modelName, gtWordsNow{w}, gtWordsNow, cleanId);
    end
end


function [cleanId noisyId gtWords correctness noisyWords] = compareLine(gtLine, noisyLine, noisyToCleanFn)
% Compare a ground truth transcript line with a noisy transcript line.
% Lines should start with utterance IDs, as used by kaldi, which should be
% space-separated from the words, which should be all-caps and
% space-separated from each other.
gtWords = split(gtLine, ' ');
noisyWords = split(noisyLine, ' ');

noisyId = noisyWords{1};
cleanId = noisyToCleanFn(gtWords{1});

gtWords = gtWords(2:end);
noisyWords = noisyWords(2:end);

if (length(gtWords) == length(noisyWords)) && all(strcmp(gtWords, noisyWords))
    % Shortcut: avoid dynamic programming if they are equal
    correctness = ones(size(gtWords));
else
    cost = zeros(length(noisyWords), length(gtWords));
    for i = 1:length(gtWords)
        cost(:,i) = 1 - strcmp(gtWords{i}, noisyWords);
    end
    
    [p,q] = dp(cost);
    % q is for gtWords, p for noisyWords
    correctness = false(size(gtWords));
    for qv = 1:length(gtWords)
        % If the alignment of the noisy transcript with the clean includes the
        % target clean word, then it is classified as correct.  This "any" is
        % susceptible to over-production of words, so insertions are not
        % penalized at all.
        correctness(qv) = any(strcmp(gtWords(q(q ==qv)), noisyWords(p(q == qv))));
    end
end
1+1;


function printScoredWords(words, scores, sentenceScore)
fprintf('%0.3f  ', sentenceScore);
for i = 1:length(words)
    fprintf('%s:%0.3f ', words{i}, scores(i));
end
fprintf('\n');


function createResultFile(resultPath, noisyIdToFileMap, noisyIds, correctness, modelName, gtWord, gtWordsNow, cleanId)

grouped = cell(length(noisyIds), 6);
for n = 1:length(noisyIds)
    noisyFile = noisyIdToFileMap.(['id' noisyIds{n}]);
    isCorrect = correctness(n);
    if isCorrect
        guess = gtWord;
    else
        guess = '';
    end
    grouped(n,:) = {modelName, '', noisyFile, guess, isCorrect, gtWord};
end
digested = grouped;
equivClasses = [];
responseCounts = nan*ones(size(grouped,1),1);

ensureDirExists(resultPath);
save(resultPath, 'grouped', 'digested', 'gtWordsNow', 'cleanId', 'equivClasses', 'responseCounts');


function printSentenceConfusions(gtWords, noisyWords)

gtSents = listMap(@(x) chop(join(x, ' ')), gtWords);
noisySents = listMap(@(x) chop(join(x, ' ')), noisyWords);
[C labels] = confusionmat(gtSents, noisySents);
C = [C sum(C,2); sum(C,1) sum(C(:))];
labels{end+1} = 'Sum';
for i = 1:size(C,1)
    fprintf('%s\t', labels{i});
    fprintf('% 4d ', C(i,:));
    fprintf('\n');
end
