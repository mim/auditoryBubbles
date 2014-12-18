function [correct incorrect picked] = playFileGetAndSaveChoice(file, rightAnswer, ...
    outCsvFile, subjectName, words, choiceNums, allowRepeats, ...
    giveFeedback, correct, incorrect, curIter, totalIters)

% Play a wav file and get the listener's guess as to which of a set of
% words they heard.  Saves results in csv file using csvWriteCells.

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
    catch ex % err
        % Play again and keep looping
        firstTime = false;
    end
end

% Write to file
outLine = [{file} words {datestr(clock, 30) rightAnswer picked '' subjectName}];
csvWriteCells(outCsvFile, {outLine}, 'a');

% Give feedback
if strcmp(picked, rightAnswer)
    correct = correct + 1;
    fbStr = 'Correct';
else
    incorrect = incorrect + 1;
    fbStr = 'Incorrect';
end
if giveFeedback
    fprintf('%s (finished %d of %d)\n', fbStr, curIter, totalIters)
else
    fprintf('Finished %d of %d\n', curIter, totalIters)
end
