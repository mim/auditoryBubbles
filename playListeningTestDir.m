function playListeningTestDir(inDir, subjectName, allowRepeats)

% playListeningTestDir(inDir, subjectName, [allowRepeats])
%
% Run a listening test using all of the files in a directory. Save
% results to a comma-separated variable (CSV) file in the same
% directory with a date-time-stamp.
%
% Inputs:
%   inDir         directory to find wav files to play
%   subjectName   string to save in output file signifying subject, e.g. initials
%   allowRepeats  if 1, allow user to replay sounds, if 0, do not (defaults to 0)

if ~exist('allowRepeats', 'var') || isempty(allowRepeats), allowRepeats = false; end

outCsvFile = fullfile(inDir, [subjectName '_' datestr(clock, 30) '.csv']);
choiceNums = [1 2 3 4 5 6];

% Load all files, randomize them
[~,files] = findFiles(inDir, '.wav$');
files = files(randperm(length(files)));

% Figure out right answers, possible choices
rightAnswers = listMap(@figureOutRightAnswerFromFileName, files);
words = unique(rightAnswers)';
assert(length(choiceNums) == length(words))
correct = 0; incorrect = 0;

% Write headers in output file
outHeader = {'Intput.file1'};
for i = 1:length(words)
    outHeader{end+1} = sprintf('Input.word1%d', i);
end
outHeader{end+1} = 'Timestamp';
outHeader{end+1} = 'Input.rightAnswer1';
outHeader{end+1} = 'Answer.wordchoice1';
outHeader{end+1} = 'RejectionTime';
outHeader{end+1} = 'WorkerId';
csvWriteCells(outCsvFile, {outHeader}, 'w');

% Run them
for f = 1:length(files)
    file = files{f};
        
    % Print prompt
    fprintf('\n')
    for opt = 1:length(words)
        fprintf('%d: %-7s  ', choiceNums(opt), words{opt});
    end
    if allowRepeats
        fprintf('%d: [replay]', 0);
    end
    fprintf('\n')
    
    [mix sr] = wavReadBetter(file);
    
    % Get input robustly
    firstTime = true;
    while true
        try
            if firstTime || allowRepeats
                % Play mixture
                sound(mix, sr);
            end
            
            choice = input('Which word did you hear? ');
            picked = words{choiceNums == choice};
            break
        catch % err
            % Play again and keep looping
            firstTime = false;
        end
    end
    
    % Write to file
    outLine = [{file} words {datestr(clock, 30) rightAnswers{f} picked '' subjectName}];
    csvWriteCells(outCsvFile, {outLine}, 'a');

    % Give feedback
    if strcmp(picked, rightAnswers{f})
        correct = correct + 1;
        fprintf('Correct (finished %d of %d)\n', f, length(files))
    else
        incorrect = incorrect + 1;
        fprintf('Incorrect (finished %d of %d)\n', f, length(files))
    end
end
fprintf('Avg %g%% correct\n', 100*correct / (correct + incorrect));


function word = figureOutRightAnswerFromFileName(fileName)

[d f] = fileparts(fileName);
parts = split(f, '_');
word = parts{1};
