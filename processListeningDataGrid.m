function processListeningDataGrid(inCsvFiles, outGroupedFileBase, verbose, ignoreStimulusDir, posThresh, negThresh, unpackFn, printConfMat)

% Convert listening test files from GRID utterances for further analysis
%
%   processListeningData(inCsvFiles, outGroupedFile, verbose)
%
% Calls processListeningData with different equivalence classes
% derived from words in GRID utterances.  Filenames should start
% with 6-letter GRID sentence identifiers, which use initial
% letters/numbers from each word in the sentence.

if ~exist('unpackFn', 'var') || isempty(unpackFn), unpackFn = @unpackShsCsv; end
if ~exist('ignoreStimulusDir', 'var') || isempty(ignoreStimulusDir), ignoreStimulusDir = 0; end
if ~exist('posThresh', 'var') || isempty(posThresh), posThresh = 0.9; end
if ~exist('negThresh', 'var') || isempty(negThresh), negThresh = 0.6; end
if ~exist('verbose', 'var') || isempty(verbose), verbose = 1; end
if ~exist('printConfMat', 'var') || isempty(printConfMat), printConfMat = false; end

outGroupedFileBase = regexprep(outGroupedFileBase, '.mat$', '');

fprintf('Overall\n');
[grouped digested] = processListeningData(inCsvFiles, outGroupedFileBase, verbose, ...
                     ignoreStimulusDir, posThresh, negThresh, ...
                     {}, unpackFn, printConfMat);

rightAnswers = digested(:,6);
choices = unique(rightAnswers);

for pos = 1:length(rightAnswers{1})
    choiceAtPos = listMap(@(x) x(pos), choices);
    [a b c] = unique(choiceAtPos);
    if length(a) <= 1
        continue
    end

    fprintf('Pos %d: {%s}\n', pos, join(choiceAtPos, ','))
    for eq = 1:length(a)
        eqc{eq} = choices(c == eq);
    end
    
    groupedFile = sprintf('%s_p%d.mat', outGroupedFileBase, pos);

    processListeningData(inCsvFiles, groupedFile, verbose, ...
                         ignoreStimulusDir, posThresh, negThresh, ...
                         eqc, unpackFn);
end
