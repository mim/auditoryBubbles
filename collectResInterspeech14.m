function collectResInterspeech14()

% Collect data from expWarpExtensive, format into tables for interspeech paper

% cross-validation within each track
allRes = loadAcc(2:6:36, 'xvalSvmOnEachWord');  % Same talker
xvalAcc(1:3,:,:) = allRes(1:3,:,:);
allRes = loadAcc(1:6:36, 'xvalSvmOnEachWord');  % Different talkers
xvalAcc(4:6,:,:) = allRes([1 3 4],:,:);
xvalAcc(7,:,:) = mean(xvalAcc,1);

% rows: same talker v1,2,3, different talker 2,3,4
% cols: acha, ada, afa, aja, ata, ava
printLatexTable(xvalAcc(:,:,1), '%0.1f');

% train 2, test 1, same talker
[t2t1SameAcc t2t1SameAccDiffWord] = loadAcc(2:6:36, 'trainSvmOnAllButOne');
table2 = [permute(mean(t2t1SameAcc,1), [3 2 1]);
    permute(mean(t2t1SameAccDiffWord,1), [3 2 1])];
printLatexTable(table2, '%0.1f');

% train 2, test 1, different talker
[t2t1DiffAcc t2t1DiffAccDiffWord] = loadAcc(1:6:36, 'trainSvmOnAllButOne');
table3 = [permute(mean(t2t1DiffAcc,1), [3 2 1]);
    permute(mean(t2t1DiffAccDiffWord,1), [3 2 1])];
printLatexTable(table3, '%0.1f');


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

function printLatexTable(X, format)
if nargin < 2, format = '%g'; end

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
