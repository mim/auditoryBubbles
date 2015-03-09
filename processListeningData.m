function [grouped digested] = processListeningData(inCsvFiles, outGroupedFile, verbose, ignoreStimulusDir, posThresh, negThresh, equivClassCell, unpackFn)

% Convert listening test files for further analysis
%
%   processListeningData(inCsvFiles, outGroupedFile, verbose)
%
% Inputs:
%   inCsvFiles      cell array of CSV files generated by playListeningTestDir
%   outGroupedFile  mat file to write processed results into
%   verbose         print some summary statistics to the console
%   ignoreStimulusDir  Remove directory from names of stimulus files (in case
%                      different subjects had them in different directories)

if ~exist('unpackFn', 'var') || isempty(unpackFn), unpackFn = @unpackShsCsv; end
if ~exist('ignoreStimulusDir', 'var') || isempty(ignoreStimulusDir), ignoreStimulusDir = 0; end
if ~exist('posThresh', 'var') || isempty(posThresh), posThresh = 0.9; end
if ~exist('negThresh', 'var') || isempty(negThresh), negThresh = 0.6; end
if ~exist('verbose', 'var') || isempty(verbose), verbose = 1; end
if ~exist('equivClassCell', 'var'), equivClassCell = {}; end

if ~iscell(inCsvFiles), inCsvFiles = {inCsvFiles}; end

digestedFile = tempname;
for i = 1:length(inCsvFiles)
    unpackFn(inCsvFiles{i}, digestedFile);
end

digested = csvReadCells(digestedFile);
if isempty(equivClassCell)
    rightAnswers = unique(digested(:,4));
    for i = 1:length(rightAnswers)
        equivClassCell{i} = rightAnswers(i);
    end
end
for i = 1:length(equivClassCell)
    for j = 1:length(equivClassCell{i})
        equivClasses.(equivClassCell{i}{j}) = i;
    end
end

for i=1:size(digested,1)
    rightAnswer = regexprep(basename(digested{i,3}), '_.*', ''); 
    digested{i,6} = rightAnswer;

    if isempty(digested{i,4})
        digested{i,5} = 0; 
    else
        digested{i,5} = equivClasses.(rightAnswer) == equivClasses.(digested{i,4}); 
    end
    
    if ignoreStimulusDir
        digested{i,3} = basename(digested{i,3});
    end
end

grouped = groupBy(digested, 3, @(x) basename(x,1), 3, @(x) mean([x{:}]), 5);
grouped(:,7) = listMap(@(x) (x >= posThresh) - (x < negThresh), grouped(:,5));

responses = grouped(:,4);
responseCounts = zeros(size(responses,1), length(equivClassCell));
for i = 1:size(responses,1)
    for j = 1:length(responses{i})
        eq = equivClasses.(responses{i}{j});
        responseCounts(i,eq) = responseCounts(i,eq) + 1;
    end
end
    
save(outGroupedFile, 'grouped', 'digested', 'equivClasses', 'responseCounts');

if verbose
    grouped2 = groupBy(digested, 6, @(x) mean([x{:}]), 5);
    fprintf('Avg:\t%0.1f%% correct\n', 100*mean([grouped{:,5}]));
    for i = 1:size(grouped2,1)
        fprintf('%s:\t%0.1f%% correct\n', grouped2{i,6}, 100*grouped2{i,5});
    end
    
    %disp('Confusion matrix (one column per true label)')
    %printConfusionMat(digested(:,4), digested(:,6));
end
