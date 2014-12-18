function writeCsvResultHeader(outCsvFile, words)

% Write header of CSV file for listening test results
% (playListeningTestDir)

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
