function [lowRows empties] = checkHits(batchFile)

file = fullfile('z:\data\mrt\mturk_csv_out\', batchFile);
digested = unpackMTurkCsv(file);
digested = cat(1, digested{:});

for i=1:size(digested,1)
    [d f] = fileparts(digested{i,3});
    digested{i,5} = strncmp(f, digested{i,4}, length(digested{i,4})); 
end

% Check "catch" questions per user
keep = reMatch(digested(:,3), '[a-z]\.wav') & cellfun(@isempty, digested(:,2));
grouped = groupBy(digested(keep,:), 1, @scoreAgg, 5);
res = cat(1, grouped{:,5});
low = find((res(:,2) > 3) & (res(:,1) < 2/3*res(:,2)));
lowRows = grouped(low);

% Check for unanswered questions
keep = cellfun(@isempty, digested(:,2)) & cellfun(@isempty, digested(:,4));
empties = groupBy(digested(keep,:), 1, @scoreAgg, 5);

% Check noisy questions per user
keep = reMatch(digested(:,3), '[0-9]\.wav') & cellfun(@isempty, digested(:,2));
grouped = groupBy(digested(keep,:), 1, @scoreAgg, 5);
res = cat(1, grouped{:,5});
subplot 211
plot(res(:,1), res(:,2), '.', [0 max(res(:,2))/2], [0 max(res(:,2))])

% Check noise questions per mix
grouped = groupBy(digested(keep,:), 3, @scoreAgg, 5);
subplot 212
res = cat(1, grouped{:,5});
hist(res(:,3))

subplot 111


function vec = scoreAgg(ca)
x = [ca{:}];
vec = [sum(x) length(x) mean(x)];
