function processAsrData(inKaldiDir, outResultDir, lmwtFilePattern, iter, noisyIdChars)

% Like processListeningData, but for ASR results from kaldi.  Outputs a
% directory of results files (one for each word in each clean file) instead
% of just one.
%
% processAsrData(inKaldiDir, outResultDir, [lmwtFilePattern], [iter], [noisyIdChars])
%
% inKaldiDir should be the directory in exp of one asr system, e.g.,
% /data/data8/scratch/mandelm/kaldi/chime-wsj0-s5-bubbles20-avg/exp/tri3b 
% outResultDir is the base directory where results will be written. In that
% directory they will be in a subdirectory named by the model, then the
% clean file, then the language model weight, then the file named by the
% word.
%
% Each result file is an Nx6 cell array with fields: 
%   model, [blank], noisyFile, guess, isCorrect, rightAnswer

if ~exist('noisyIdChars', 'var') || isempty(noisyIdChars), noisyIdChars = 8; end
if ~exist('iter', 'var'), iter = ''; end
if ~exist('lmwtFilePattern', 'var') || isempty(lmwtFilePattern), lmwtFilePattern = '\d+.txt'; end

if isempty(iter)
    scoringDir = fullfile(inKaldiDir, 'decode_tgpr_dev_dt_05_noisy/scoring/');
else
    scoringDir = fullfile(inKaldiDir, sprintf('decode_tgpr_dev_dt_05_noisy_it%d/scoring/', iter));
end
[~,transFiles] = findFiles(scoringDir, lmwtFilePattern);
gtFile = fullfile(scoringDir, 'test_filt.txt');
model = getModelNameFromKaldiDir(inKaldiDir);

noisyIdToFileList = fullfile(inKaldiDir, '../../data/local/data/dev_dt_05_noisy_wav.scp');
noisyIdToFileMap = makeIdToFileMap(noisyIdToFileList);

gtLines = textArray(gtFile);

for lmwti = 1:length(transFiles)
    lmwts = basename(transFiles{lmwti},0);
    fprintf('%d/%d: %s', lmwti, length(transFiles), lmwts);

    noisyLines = textArray(transFiles{lmwti});
    assert(length(gtLines) == length(noisyLines))
    
    for i = 1:length(noisyLines)-1
        [cleanIds{i} noisyIds{i} gtWords{i} correctness{i}] = compareLine(gtLines{i}, noisyLines{i}, noisyIdChars);
    end
    
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
        printScoredWords(gtWordsNow, mean(cat(1, correctness{groupIdx})))

        for w = 1:length(gtWordsNow)
            resultFile = sprintf('model=%s_clean=%s_lmwt=%s_%02d_%s.mat', model, cleanId, lmwts, w, gtWordsNow{w});
            resultPath = fullfile(outResultDir, model, resultFile);
            
            grouped = cell(length(groupIdx), 6);
            for n = 1:length(groupIdx)
                realN = groupIdx(n);
                noisyFile = noisyIdToFileMap.(['id' noisyIds{realN}]);
                isCorrect = correctness{realN}(w);
                if isCorrect
                    guess = gtWordsNow{w};
                else
                    guess = '';
                end
                grouped(n,:) = {model, '', noisyFile, guess, isCorrect, gtWordsNow{w}};
            end
            digested = grouped;
            equivClasses = [];
            responseCounts = nan*ones(size(grouped,1),1);
            
            ensureDirExists(resultPath);
            save(resultPath, 'grouped', 'digested', 'gtWordsNow', 'cleanId', 'equivClasses', 'responseCounts');
        end
    end
    printStatus('\n')
end


function [cleanId noisyId gtWords correctness] = compareLine(gtLine, noisyLine, noisyIdChars)
% Compare a ground truth transcript line with a noisy transcript line.
% Lines should start with utterance IDs, as used by kaldi, which should be
% space-separated from the words, which should be all-caps and
% space-separated from each other.
gtWords = split(gtLine, ' ');
noisyWords = split(noisyLine, ' ');

noisyId = noisyWords{1};
cleanId = noisyToCleanId(gtWords{1}, noisyIdChars);

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


function cleanId = noisyToCleanId(noisyId, noisyIdChars)
% Map a noisy file ID to a clean file ID.  A noisy file ID is a clean one
% with an extra noisyIdChars on the end that are a hash of the path to the
% noisy file.
if nargin < 2, noisyIdChars = 4; end
cleanId = noisyId(1:end-noisyIdChars);


function idToFileMap = makeIdToFileMap(idToFileList)
% Create a struct with keys idXXXXXXXX mapping a noisy file ID to an
% absolute file path
lines = textArray(idToFileList);
idToFileMap = struct();
for i = 1:length(lines)
    if isempty(lines{i}), continue; end
    
    fields = split(lines{i}, ' ');
    key = ['id' fields{1}];
    val = join(fields(2:end), ' ');
    idToFileMap.(key) = val;
end


function model = getModelNameFromKaldiDir(inKaldiDir)
% Get the name of the model from the kaldi directory we're analyzing.
% Should be the last part of the name, which is a directory, so might have
% a trailing / or not.
model = basename(inKaldiDir);
if isempty(model)
    model = basename(inKaldiDir, 0, 1);
end

function printScoredWords(words, scores)
for i = 1:length(words)
    fprintf('%s:%0.2f ', words{i}, scores(i));
end
fprintf('\n');
