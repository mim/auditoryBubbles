function keep = balanceSets(isRight, keepAll, seed, nTrain)
if nargin < 4, nTrain = inf; end
if nargin < 3, seed = ''; end
nStart = length(isRight);
pos = find(isRight == 1);
neg = find(isRight == -1);
if keepAll
    thunk = @() [randomSample(pos, inf); ...
                 randomSample(neg, inf)];
else
    numPerClass = min([length(pos) length(neg) floor(nTrain/2)]);
    thunk = @() [randomSample(pos, numPerClass); ...
                 randomSample(neg, numPerClass)];
end
if isempty(seed)
    keep = thunk();
else
    keep = runWithRandomSeed(seed, thunk);
end
%fprintf('Keeping %d of %d mixes (%d pos, %d neg)\n', ...
%    length(keep), nStart, length(pos), length(neg));

function y = randomSample(x, n)
ord = randperm(length(x));
y = x(ord(1:min(end,n)));
