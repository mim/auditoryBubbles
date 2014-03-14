function collectResInterspeech14()

% Collect data from expWarpExtensive, format into tables for interspeech paper

% cross-validation within each track
xvalAcc(1:3,:,:) = loadAcc(2:6:36, 'xvalSvmOnEachWord');  % Same talker
xvalAcc(4:7,:,:) = loadAcc(1:6:36, 'xvalSvmOnEachWord');  % Different talkers
xvalAcc(8,:,:) = mean(xvalAcc,1);

% rows: same talker v1,2,3, different talker 2,3,4
% cols: acha, ada, afa, aja, ata, ava
printLatexTable(xvalAcc(:,:,1), '%0.1f');

% train 2, test 1, same talker
t2t1SameAcc = loadAcc(2:6:36, 'trainSvmOnAllButOne');
printLatexTable(permute(mean(t2t1SameAcc,1), [3 2 1]), '%0.1f');

% train 2, test 1, different talker
t2t1DiffAcc = loadAcc(1:6:36, 'trainSvmOnAllButOne');
printLatexTable(permute(mean(t2t1DiffAcc,1), [3 2 1]), '%0.1f');


function allRes = loadAcc(targets, fn)
grouping = 0;
for target = 1:length(targets)
    for doWarp = [0 1]
        resFile = resFileFor(grouping, doWarp, targets(target), fn);
        res = load(resFile);
        allRes(:,target,doWarp+1) = (1 - res.mcr') * 100;
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

baseDir = 'C:\Temp\data\results\exp12\trim=30,length=2.2\';
path = fullfile(baseDir, ...
    sprintf('grouping=%d', grouping), ...
    sprintf('doWarp=%d', doWarp), ...
    sprintf('target=%d', target), ...
    sprintf('fn=%s', fn), ...
    'res.mat');
