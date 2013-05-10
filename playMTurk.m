function playMTurk(inCsvFile)

% "Play" mechanical turk HITs locally with matlab

outCsvFile = fullfile('Z:\data\mrt\mturk_csv_out', ['mim_' datestr(clock, 30) '.csv']);
numChoices = 6;
fieldsPerUrl = numChoices + 1;

hits = csvReadCells(inCsvFile);
header = hits(1,:);
hits = hits(2:end,:);  % Strip off header

hits = hits(randperm(size(hits,1)),:);
urlsPerHit = size(hits,2) / fieldsPerUrl;

outHeader = listMap(@(x) ['Input.' x], header);
outHeader{end+1} = 'Timestamp';
for i = 1:urlsPerHit
    outHeader{end+1} = sprintf('Answer.wordchoice%d', i);
end
outHeader{end+1} = 'RejectionTime';
outHeader{end+1} = 'WorkerId';
csvWriteCells(outCsvFile, {outHeader}, 'w');

for h = 1:size(hits,1)
    for u = 1:urlsPerHit
        url = hits{h, (u-1)*fieldsPerUrl+1};
        words = hits(h, (u-1)*fieldsPerUrl+2:u*fieldsPerUrl);
        
        % Print prompt
        fprintf('\n')
        for opt = 1:size(words,2);
            fprintf('%d: %-7s  ', opt, words{opt});
        end
        fprintf('%d: [play again]', size(words,2)+1);
        fprintf('\n')
        
        [mix sr] = s3CachedWavRead(url);
        
        % Get input robustly
        while true
            try
                % Play mixture
                sound(mix, sr);
                
                choice = input('Which word did you hear? ');
                picked{u} = words{choice};
                break
            catch err
                % Play again and keep looping
            end
        end
    end
    
    outLine = [hits(h,:) {datestr(clock, 30)} picked {'', 'mim'}];
    fprintf('Completed HIT %d of %d\n' , h, size(hits,1));
    csvWriteCells(outCsvFile, {outLine}, 'a');
end
