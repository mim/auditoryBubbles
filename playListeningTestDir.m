function playListeningTestDir(inDir, subjectName, giveFeedback, ...
                              allowRepeats, vertical)

% playListeningTestDir(inDir, subjectName, [giveFeedback], [allowRepeats])
% playListeningTestDir(inDir, existingResultFileName, [giveFeedback], [allowRepeats])
%
% Run a listening test using all of the files in a directory. Save
% results to a comma-separated value (CSV) file in the same
% directory with a date-time-stamp.  If the name of an existing file is
% given as the second argument instead of a subject name, continue that
% experiment and write to that file instead of starting over.
%
% Inputs:
%   inDir         directory to find wav files to play
%   subjectName   string to save in output file signifying subject, e.g. initials
%   giveFeedback  if 1, tell the user whether their response was correct or not, if 0, do not (defaults to 0)
%   allowRepeats  if 1, allow user to replay sounds, if 0, do not (defaults to 0)

if ~exist('allowRepeats', 'var') || isempty(allowRepeats), allowRepeats = false; end
if ~exist('giveFeedback', 'var') || isempty(giveFeedback), giveFeedback = false; end
if ~exist('vertical', 'var') || isempty(vertical), vertical = false; end

% If subjectName is actually a file name, then use that directly as the
% output file (and save a backup of the current version)
if exist(fullfile(inDir, subjectName), 'file')
    outCsvFile = fullfile(inDir, subjectName);
    restarting = 1;
elseif exist(subjectName, 'file') == 2
    outCsvFile = subjectName;
    restarting = 1;
else
    outCsvFile = fullfile(inDir, [subjectName '_' datestr(clock, 30) '.csv']);
    restarting = 0;
end

% Figure out which files have already been done to exclude them
doneFiles = {};
if exist(outCsvFile, 'file')
    doneCsv = csvReadCells(outCsvFile);
    if size(doneCsv,1) > 1
        doneFiles = doneCsv(2:end,1);
    end
end
    
% Load all files, randomize them
[~,files] = findFiles(inDir, '.wav$');
files = basenameSetDiff(files, doneFiles);
files = files(randperm(length(files)));
fprintf('Using %d files\n', length(files));

% Figure out right answers, possible choices
rightAnswers = listMap(@figureOutRightAnswerFromFileName, files);
words = unique(rightAnswers)';
if length(words) ~= 6
    warning('Using %d choices instead of 6', length(words))
end
choiceNums = 1:length(words);
correct = 0; incorrect = 0;

if restarting
    copyfile(outCsvFile, [outCsvFile '.bak']);
else
    writeCsvResultHeader(outCsvFile, words);
end

% Run them
for f = 1:length(files)
    file = files{f};
    
    [correct incorrect] = playFileGetAndSaveChoice(file, rightAnswers{f}, ...
        outCsvFile, subjectName, words, choiceNums, allowRepeats, ...
        giveFeedback, correct, incorrect, f, length(files), vertical);
end
fprintf('Avg %g%% correct\n', 100*correct / (correct + incorrect));


function c = basenameSetDiff(a, b)
% Remove files from a that are in b, only based on basename, not
% directory.

ab = listMap(@basename, a);
bb = listMap(@basename, b);
[cb,i] = setdiff(ab, bb);
c = a(i);
