function collectResInterspeech14()

% Collect data from expWarpExtensive, format into tables for interspeech paper

% cross-validation within each track
allRes = loadAcc(2:6:36, 'xvalSvmOnEachWord');  % Same talker
xvalAcc(1:3,:,:) = allRes(1:3,:,:);
allRes = loadAcc(1:6:36, 'xvalSvmOnEachWord');  % Different talkers
xvalAcc(4:6,:,:) = allRes([1 3 4],:,:);
xvalAcc(7,:,:) = mean(xvalAcc,1);

% rows: same talker v1,2,3, different talker 2,3,4, average
% cols: acha, ada, afa, aja, ata, ava
printLatexTable(xvalAcc(:,:,1), '%0.1f', 'Cross validation per utterance');


[allNTe allNTr] = loadXvalNumTest(2:6:36);  % Same talker
nTe(1:3,:,:) = allNTe(1:3,:,:);
nTr(1:3,:,:) = allNTr(1:3,:,:);
[allNTe allNTr] = loadXvalNumTest(1:6:36);  % Different talker
nTe(4:6,:,:) = allNTe([1 3 4],:,:);
nTe(7,:,:) = sum(nTe,1);
nTr(4:6,:,:) = allNTr([1 3 4],:,:);
nTr(7,:,:) = mean(nTr,1);

% rows: same talker v1,2,3, different talker 2,3,4, total
% cols: acha, ada, afa, aja, ata, ava
printLatexTable(nTr(:,:,1), '%0.1f', 'Number of training instances per utterance');
printLatexTable(nTe(:,:,1), '%d', 'Number of test instances per utterance');


% train 2, test 1, same talker
[t2t1SameAcc t2t1SameAccDiffWord] = loadAcc(2:6:36, 'trainSvmOnAllButOne');
table2 = [permute(mean(t2t1SameAcc,1), [3 2 1]);
    permute(mean(t2t1SameAccDiffWord,1), [3 2 1])];
printLatexTable(table2, '%0.1f', 'Cross validation accuracy for single talker');

[t2t1SameNTe t2t1SameNTeDiffWord t2t1SameNTr] = loadTtNumTest(2:6:36, 'trainSvmOnAllButOne');
table2te = [permute(sum(t2t1SameNTe, 1), [3 2 1]);
    permute(sum(t2t1SameNTeDiffWord, 1), [3 2 1])];
table2tr = permute(mean(t2t1SameNTr, 1), [3 2 1]);
printLatexTable(table2tr, '%d', 'Number of training instances for single talker');
printLatexTable(table2te, '%d', 'Number of test instances for single talker');

% train 2, test 1, different talker
[t2t1DiffAcc t2t1DiffAccDiffWord] = loadAcc(1:6:36, 'trainSvmOnAllButOne');
table3 = [permute(mean(t2t1DiffAcc,1), [3 2 1]);
    permute(mean(t2t1DiffAccDiffWord,1), [3 2 1])];
printLatexTable(table3, '%0.1f', 'Cross validation accuracy for different talkers');

[t2t1DiffNTe t2t1DiffNTeDiffWord t2t1DiffNTr] = loadTtNumTest(1:6:36, 'trainSvmOnAllButOne');
table3te = [permute(sum(t2t1DiffNTe, 1), [3 2 1]);
    permute(sum(t2t1DiffNTeDiffWord, 1), [3 2 1])];
table3tr = permute(mean(t2t1DiffNTr, 1), [3 2 1]);
printLatexTable(table3tr, '%d', 'Number of training instances for different talkers');
printLatexTable(table3te, '%d', 'Number of test instances for different talkers');


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

function [nTe nTr] = loadXvalNumTest(targets)
grouping = 0;
fn = 'xvalSvmOnEachWord';
for target = 1:length(targets)
    for doWarp = [0 1]
        resFile = resFileFor(grouping, doWarp, targets(target), fn);
        res = load(resFile);
        for v = 1:length(res.data)
            nTe(v,target,doWarp+1) = sum(sum(cat(1, res.data{v}.nTe), 1), 2);
            nTr(v,target,doWarp+1) = mean(sum(cat(1, res.data{v}.nTr), 2), 1);
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

function printLatexTable(X, format, name)
if nargin < 2, format = '%g'; end
if nargin < 3, name = ''; end

fprintf('\n%s\n', name);
fprintf(['\\begin{tabular}{' repmat('c', 1, size(X,2)) '}\n']);
for r = 1:size(X,1)
    row = listMap(@(x) sprintf(format, x), num2cell(X(r,:)));
    fprintf('%s \\\\ \n', join(row, ' & '))
end
fprintf('\\end{tabular}\n')


function path = resFileFor(grouping, doWarp, target, fn)

baseDir = 'C:\Temp\data\results3dw\exp12\trim=30,length=2.2\';
path = fullfile(baseDir, ...
    sprintf('grouping=%d', grouping), ...
    sprintf('doWarp=%d', doWarp), ...
    sprintf('target=%d', target), ...
    sprintf('fn=%s', fn), ...
    'res.mat');
