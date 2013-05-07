function urlLines = genCsvForMturk(words, s3dirs, mixes, fileTag, nRep, urlsPerHit, wordsPerUrl)

% Generate a CSV file for use in mechanical turk
%
% lines = genCsvForMturk(words, s3dirs, mixes, outFile, nRep, urlsPerHit)
%
% Input arguments:
% words    cell array of one set of six words to be tested
% s3dirs   cell array of directories on S3 where the wavs live
% mixes    cell array of file suffixes corresponding to each mix
% fileTag  a tag to be inserted into the standard output file name
% nRep     the number of repetitions of each file to include
%
% Final url for each word is http://s3.amazonaws.com/mim.cse.osu/auditoryBubbles/[s3dir]/[word][mix].wav

if ~exist('wordsPerUrl', 'var') || isempty(wordsPerUrl), wordsPerUrl = min(6, length(words)); end
if ~exist('urlsPerHit', 'var') || isempty(urlsPerHit), urlsPerHit = 5; end
if ~exist('nRep', 'var') || isempty(nRep), nRep = 3; end
if ~exist('fileTag', 'var'), fileTag = ''; end

baseUrl = 'https://s3.amazonaws.com/mim.cse.osu/auditoryBubbles';
outFile = fullfile('Z:\data\mrt\mturk_csv_in', [fileTag '_' datestr(clock, 30) '.csv']);

if ~iscell(s3dirs), s3dirs = {s3dirs}; end

% Create header
header = {};
for u = 1:urlsPerHit
    header{end+1} = sprintf('url%d', u);
    for w = 1:wordsPerUrl
        header{end+1} = sprintf('word%d%d', u, w);
    end
end

% Create per-url choices
urlLines = {};
for d = 1:length(s3dirs)
    for w = 1:length(words)
        for m = 1:length(mixes)
            for r = 1:nRep
                url = sprintf('%s/%s/%s%s.wav', baseUrl, s3dirs{d}, words{w}, mixes{m});
                ord = randperm(length(words));
                ord = ord(1:wordsPerUrl);
                if ~any(w == ord)
                    truePos = ceil(rand(1)*wordsPerUrl);
                    ord(truePos) = w;
                end
                urlLines{end+1} = [{url} words(ord)];
            end
        end
    end
end
urlLines = urlLines(randperm(length(urlLines)));

% Combine per-url choices into HITs of urlsPerHit
for i = 1:length(urlLines)/urlsPerHit
    ind = (i-1)*urlsPerHit+1 : i*urlsPerHit;
    lines{i} = cat(2, urlLines{ind});
end
fprintf('Created %d HITs\n', length(lines))

csvWriteCells(outFile, [{header} lines]);
