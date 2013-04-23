function urlLines = genCsvForMturk(words, s3dir, mixes, fileTag, nRep, urlsPerHit)

% Generate a CSV file for use in mechanical turk
%
% lines = genCsvForMturk(words, baseUrl, mixes, outFile, nRep, urlsPerHit)
%
% Input arguments:
% words    cell array of one set of six words to be tested
% s3dir    the directory on S3 where the wavs live
% mixes    cell array of file suffixes corresponding to each mix
% fileTag  a tag to be inserted into the standard output file name
% nRep     the number of repetitions of each file to include
%
% Final url for each word is http://s3.amazonaws.com/mim.cse.osu/auditoryBubbles/[s3dir]/[word][mix].wav

if ~exist('urlsPerHit', 'var') || isempty(urlsPerHit), urlsPerHit = 5; end
if ~exist('nRep', 'var') || isempty(nRep), nRep = 3; end
if ~exist('fileTag', 'var'), fileTag = ''; end

baseUrl = 'http://s3.amazonaws.com/mim.cse.osu/auditoryBubbles';
outFile = fullfile('Z:\data\mrt\mturk_csv_in', [fileTag '_' datestr(clock, 30) '.csv']);

% Create header
header = {};
for u = 1:urlsPerHit
    header{end+1} = sprintf('url%d', u);
    for w = 1:length(words)
        header{end+1} = sprintf('word%d%d', u, w);
    end
end

% Create per-url choices
urlLines = {};
for w = 1:length(words)
    for m = 1:length(mixes)
        for r = 1:nRep
            url = sprintf('%s/%s/%s%s.wav', baseUrl, s3dir, words{w}, mixes{m});
            ord = randperm(length(words));
            urlLines{end+1} = [{url} words(ord)];
        end
    end
end
urlLines = urlLines(randperm(length(urlLines)));

% Combine per-url choices into HITs of urlsPerHit
for i = 1:(length(urlLines)-1)/urlsPerHit
    ind = (i-1)*urlsPerHit+1 : i*urlsPerHit;
    lines{i} = cat(2, urlLines{ind});
end

csvWriteCells(outFile, [{header} lines]);
