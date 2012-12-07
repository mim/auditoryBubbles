function [R uPaths Rr cr] = summarizeResults(resultsFile, keepPathPattern, sortByCorrect)

if ~exist('resultsFile', 'var') || isempty(resultsFile), resultsFile = 'z:\data\mrt\results.csv'; end
if ~exist('keepPathPattern', 'var') || isempty(keepPathPattern), keepPathPattern = '.'; end
if ~exist('sortByCorrect', 'var') || isempty(sortByCorrect), sortByCorrect = true; end

[path answer pick isRight t1 t2] = textread(resultsFile, '%s\t%s\t%s\t%d\t%f\t%f\n');

keep    = cellfun(@(x) reMatch(x, keepPathPattern), path);
path    = path(keep);
answer  = answer(keep);
pick    = pick(keep);
isRight = isRight(keep);
t1      = t1(keep);
t2      = t2(keep);

[uPaths,~,whichPath] = unique(path);

[uAnswers,~,whichAnswer] = unique(answer);
answerHist = hist(whichAnswer, unique(whichAnswer));

[uPicks,~,whichPick] = unique(pick);
pickHist = hist(whichPick, unique(whichPick));
assert(~all(keep) || all(strcmp(uAnswers, uPicks)))

nPaths = length(uPaths);
nWords = length(uPicks);

R = zeros(nPaths, nWords);
n = zeros(nPaths, 1);
nr = zeros(nPaths, 1);
Rr = zeros(nPaths, 1);

for i = 1:length(whichPath)
    R(whichPath(i), whichPick(i)) = R(whichPath(i), whichPick(i)) + 1;
    Rr(whichPath(i)) = whichAnswer(i);
    n(whichPath(i))  = n(whichPath(i)) + 1;
    nr(whichPath(i)) = nr(whichPath(i)) + isRight(i);
end

if sortByCorrect
    key = 1000 * Rr - nr./n;
    [~,fileOrd] = sort(key);
    R  = R(fileOrd,:);
    Rr = Rr(fileOrd);
    cr = nr(fileOrd) ./ n(fileOrd);
    uPaths = uPaths(fileOrd);
end

Rn = bsxfun(@rdivide, R, sum(R, 2));

subplots({R, Rn, cr})

