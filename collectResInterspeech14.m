function collectResInterspeech14()

% Collect data from expWarpExtensive, format into tables for interspeech paper

sameTalkerInds = 2:6:36;
diffTalkerInds = 5:6:36;
diffTalkersOnly = [1 2 4];
talkerIds = {'1v3', '1v2', '1v1', '2', '3', '4'};
longTalkerIds = {'1v3', '1v2', '1v1', '2', '3', '1v1', '4'};
colNames = {'acha', 'ada', 'afa', 'aja', 'ata', 'ava'};
summaryRowNames = {'Right & $-$', 'Right & $+$', 'Wrong & $-$', 'Wrong & $+$', '\multicolumn{2}{c}{Cross-val}'};

% cross-validation within each track
allRes = loadAcc(sameTalkerInds, 'xvalSvmOnEachWord');  % Same talker
xvalAcc(1:3,:,:) = allRes(1:3,:,:);
allRes = loadAcc(diffTalkerInds, 'xvalSvmOnEachWord');  % Different talkers
xvalAcc(4:6,:,:) = allRes(diffTalkersOnly,:,:);
xvalAcc(7,:,:) = mean(xvalAcc,1);

% % rows: same talker v1,2,3, different talker 2,3,4, average
% % cols: acha, ada, afa, aja, ata, ava
%printLatexTable(xvalAcc(:,:,1), '%0.1f', 'Cross validation accuracy per utterance');


[allNTe allNTr allGtClassDist] = loadXvalNumTest(sameTalkerInds);  % Same talker
nTe(1:3,:,:) = allNTe(1:3,:,:);
nTr(1:3,:,:) = allNTr(1:3,:,:);
gtClassDist(1:3,:,:) = allGtClassDist(1:3,:,:);
[allNTe allNTr allGtClassDist] = loadXvalNumTest(diffTalkerInds);  % Different talker
nTe(4:6,:,:) = allNTe(diffTalkersOnly,:,:);
nTe(7,:,:) = sum(nTe,1);
nTr(4:6,:,:) = allNTr(diffTalkersOnly,:,:);
nTr(7,:,:) = mean(nTr,1);
gtClassDist(4:6,:,:) = allGtClassDist(diffTalkersOnly,:,:);

% rows: same talker v1,2,3, different talker 2,3,4, total
% cols: acha, ada, afa, aja, ata, ava
printLatexTable(nTr(:,:,1), '%0.1f', 'Number of training instances per utterance', [], [talkerIds {'Avg'}], colNames);
printLatexTable(nTe(:,:,1), '%d', 'Number of test instances per utterance', [], [talkerIds {'Total'}], colNames);
printLatexTable(gtClassDist(:,:,1), '%0.1f', 'Percent of responses correct', [], [talkerIds {'Avg'}], colNames);

% rows: same talker v1,2,3, different talker 2,3,4, average
% cols: acha, ada, afa, aja, ata, ava
isSig = significantBinomial(xvalAcc(:,:,1), nTe(:,:,1));
printLatexTable(xvalAcc(:,:,1), '%0.1f', 'Cross validation accuracy per utterance', isSig, [talkerIds {'Avg'}], colNames);

% train 2, test 1, same talker
[t2t1SameAcc t2t1SameAccDiffWord] = loadAcc(sameTalkerInds, 'trainSvmOnAllButOne');
table2 = [permute(mean(t2t1SameAcc,1), [3 2 1]);
    permute(mean(t2t1SameAccDiffWord,1), [3 2 1]);
    mean(xvalAcc(1:3,:,1), 1)];
printLatexTable(table2, '%0.1f', 'Cross-utterance accuracy for single talker', [], summaryRowNames, colNames);

[t2t1SameNTe t2t1SameNTeDiffWord t2t1SameNTr] = loadTtNumTest(sameTalkerInds, 'trainSvmOnAllButOne');
table2te = [permute(sum(t2t1SameNTe, 1), [3 2 1]);
    permute(sum(t2t1SameNTeDiffWord, 1), [3 2 1]);
    sum(nTe(1:3,:,1),1)];
table2tr = permute(mean(t2t1SameNTr, 1), [3 2 1]);
printLatexTable(table2tr, '%d', 'Number of training instances for single talker', [], {}, colNames);
printLatexTable(table2te, '%d', 'Number of test instances for single talker', [], summaryRowNames, colNames);

%isSig = significantBinomial(table2, table2te);
%printLatexTable(table2, '%0.1f', 'Cross validation accuracy for single talker', isSig);

% train 2, test 1, different talker
[t2t1DiffAcc t2t1DiffAccDiffWord] = loadAcc(diffTalkerInds, 'trainSvmOnAllButOne');
table3 = [permute(mean(t2t1DiffAcc,1), [3 2 1]);
    permute(mean(t2t1DiffAccDiffWord,1), [3 2 1]);
    mean(xvalAcc(3:6,:,1),1)];
printLatexTable(table3, '%0.1f', 'Cross-utterance accuracy for different talkers', [], summaryRowNames, colNames);

[t2t1DiffNTe t2t1DiffNTeDiffWord t2t1DiffNTr] = loadTtNumTest(diffTalkerInds, 'trainSvmOnAllButOne');
table3te = [permute(sum(t2t1DiffNTe, 1), [3 2 1]);
    permute(sum(t2t1DiffNTeDiffWord, 1), [3 2 1]);
    sum(nTe(3:6,:,1),1)];
table3tr = permute(mean(t2t1DiffNTr, 1), [3 2 1]);
printLatexTable(table3tr, '%d', 'Number of training instances for different talkers', [], {}, colNames);
printLatexTable(table3te, '%d', 'Number of test instances for different talkers', [], summaryRowNames, colNames);

%isSig = significantBinomial(table3, table3te);
%printLatexTable(table3, '%0.1f', 'Cross validation accuracy for different talkers', isSig);

% Warped per-utterance cross-utterance results
table4 = [t2t1SameAcc; t2t1DiffAcc];
table4 = [table4; mean(table4,1)];
table4te = [t2t1SameNTe; t2t1DiffNTe];
table4te = [table4te; sum(table4te,1)];
isSig = significantBinomial(table4, table4te);
printLatexTable(table4(:,:,1), '%0.1f', 'Cross-utterance accuracy without warping tested on each utterance', isSig(:,:,1), [longTalkerIds {'Avg'}], colNames);
printLatexTable(table4(:,:,2), '%0.1f', 'Cross-utterance accuracy with warping tested on each utterance', isSig(:,:,2), [longTalkerIds {'Avg'}], colNames);



function [allRes allResDiffWord] = loadAcc(targets, fn)
grouping = 0;
allResDiffWord = [];
for target = 1:length(targets)
    for doWarp = [0 1]
        resFile = resFileFor(grouping, doWarp, targets(target), fn);
        res = load(resFile);
        allRes(:,target,doWarp+1) = (1 - res.mcr(:,1)) * 100;
        if size(res.mcr,2) > 1
            allResDiffWord(:,target,doWarp+1) = (1 - res.mcr(:,2)) * 100;
        end
    end
end

function [nTe nTr gtClassDist] = loadXvalNumTest(targets)
grouping = 0;
fn = 'xvalSvmOnEachWord';
for target = 1:length(targets)
    for doWarp = [0 1]
        resFile = resFileFor(grouping, doWarp, targets(target), fn);
        res = load(resFile);
        for v = 1:length(res.data)
            nTe(v,target,doWarp+1) = sum(sum(cat(1, res.data{v}.nTe), 2), 1);
            nTr(v,target,doWarp+1) = mean(sum(cat(1, res.data{v}.nTr), 2), 1);
            gtClassDist(v,target,doWarp+1) = res.data{v}(1).unbalanced(1) / sum(res.data{v}(1).unbalanced) * 100;
        end
    end
end

function [nTe nTeDw nTr] = loadTtNumTest(targets, fn)
grouping = 0;
for target = 1:length(targets)
    for doWarp = [0 1]
        resFile = resFileFor(grouping, doWarp, targets(target), fn);
        res = load(resFile);
        nTr(:,target,doWarp+1) = sum(res.nTr, 2);
        rnTe = sum(res.nTe, 3);
        nTe(:,target,doWarp+1) = rnTe(:,1);
        nTeDw(:,target,doWarp+1) = rnTe(:,2);
    end
end

function isSig = significantBinomial(acc, nTe)
k = acc(:)/100 .* nTe(:);
n = nTe(:);
[~,pc] = binofit(k, n);
isSig = pc(:,1) > 0.5;
isSig = reshape(isSig, size(nTe));

function isSig = compareProportions(p1, p2, n1, n2)
% score test for two proportions. see slide 13 of http://ocw.jhsph.edu/courses/methodsinbiostatisticsii/PDFs/lecture18.pdf
% Determine whether p1 is significantly bigger than p2 under a
% normal approximation of a binomial distribution at a 0.05% level.
p = (p1.*n1 + p2.*n2) ./ (n1 + n2);
ts = (p1 - p2) ./ sqrt(p .* (1 - p) .* (1./n1 + 1./n2));
pVal = normcdf(ts);
isSig = pVal >= 0.975;

function printLatexTable(X, format, name, B, rowNames, colNames)
if ~exist('format', 'var') || isempty(format), format = '%g'; end
if ~exist('name', 'var') || isempty(name), name = ''; end
if ~exist('B', 'var') || isempty(B), B = zeros(size(X)); end
if ~exist('rowNames', 'var') || isempty(rowNames), rowNames = repmat({''}, size(X,1), 1); end
if ~exist('colNames', 'var') || isempty(colNames), colNames = repmat({''}, 1, size(X,2)); end

fprintf('\n%s\n', name);
fprintf(['\\begin{tabular}{' repmat('c', 1, size(X,2)+1) '}\n']);
fprintf('%s \\\\ \n', join([{''} colNames], ' & '));
for r = 1:size(X,1)
    row = cell(1,size(X,2)+1);
    row{1} = rowNames{r};
    for c = 1:size(X,2)
        if B(r,c)
            row{c+1} = sprintf(['\\sig{' format '}'], X(r,c));
        else
            row{c+1} = sprintf(format, X(r,c));
        end
    end
    fprintf('%s \\\\ \n', join(row, ' & '))
end
fprintf('\\end{tabular}\n')


function path = resFileFor(grouping, doWarp, target, fn)

baseDir = 'C:\Temp\data\results3dwBalTr\exp12\trim=30,length=2.2\';
path = fullfile(baseDir, ...
    sprintf('grouping=%d', grouping), ...
    sprintf('doWarp=%d', doWarp), ...
    sprintf('target=%d', target), ...
    sprintf('fn=%s', fn), ...
    'res.mat');
