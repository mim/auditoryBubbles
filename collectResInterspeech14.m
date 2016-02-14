function collectResInterspeech14(toDisk, startAt)

% Collect data from expWarpExtensive, format into tables for interspeech paper

if ~exist('toDisk', 'var') || isempty(toDisk), toDisk = false; end
if ~exist('startAt', 'var') || isempty(startAt), startAt = 0; end

outFile = '/home/data/bubblesResults/resInterspeech14/tables.tex';
sameTalkerInds = 2:6:36;
diffTalkerInds = 5:6:36;
diffTalkersOnly = [1 2 4];
sameTalkersInTables = 1:3;
diffTalkersInTables = 3:6;
talkerIds = {'W3 v3', 'W3 v2', 'W3 v1', 'W4', 'W2', 'W5'};
longTalkerIds = {'W3 v3', 'W3 v2', 'W3 v1', 'W4', 'W2', 'W3 v1', 'W5'};
colNames = {'acha', 'ada', 'afa', 'aja', 'ata', 'ava'};
summaryRowNames = {'Same & $-$', 'Same & $+$', 'Diff & $-$', 'Diff & $+$', '\multicolumn{2}{c}{Cross-val}'};

prt('ToFile', toDisk, 'StartAt', startAt, ...
    'Width', 4, 'Height', 3, 'NumberPlots', 0, ...
    'TargetDir', '/home/data/bubblesResults/resInterspeech14/accResults', ...
    'SaveTicks', 1, 'Resolution', 200)

ensureDirExists(outFile);
if exist(outFile, 'file'), delete(outFile); end

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
printLatexTable(outFile, nTr(:,:,1), '%0.1f', 'Average number of cross-validation training instances per utterance', [], [talkerIds {'Avg'}], colNames);
printLatexTable(outFile, nTe(:,:,1), '%d', 'Total number of cross-validation test instances per utterance', [], [talkerIds {'Total'}], colNames);
printLatexTable(outFile, gtClassDist(:,:,1), '%0.1f', 'Percent of responses correct', [], [talkerIds {'Avg'}], colNames);

% rows: same talker v1,2,3, different talker 2,3,4, average
% cols: acha, ada, afa, aja, ata, ava
isSig = significantBinomial(xvalAcc(:,:,1), nTe(:,:,1));
printLatexTable(outFile, xvalAcc(:,:,1), '%0.1f', 'Cross validation accuracy per utterance', isSig, [talkerIds {'Avg'}], colNames);

% train 2, test 1, same talker
[t2t1SameAcc t2t1SameAccDiffWord] = loadAcc(sameTalkerInds, 'trainSvmOnAllButOne');
table2 = [permute(mean(t2t1SameAcc,1), [3 2 1]);
    permute(mean(t2t1SameAccDiffWord,1), [3 2 1]);
    mean(xvalAcc(1:3,:,1), 1)];
printLatexTable(outFile, table2, '%0.1f', 'Cross-utterance accuracy for single talker', [], summaryRowNames, [{''} colNames]);

[t2t1SameNTe t2t1SameNTeDiffWord t2t1SameNTr] = loadTtNumTest(sameTalkerInds, 'trainSvmOnAllButOne');
table2te = [permute(sum(t2t1SameNTe, 1), [3 2 1]);
    permute(sum(t2t1SameNTeDiffWord, 1), [3 2 1]);
    sum(nTe(1:3,:,1),1)];
table2tr = permute(mean(t2t1SameNTr, 1), [3 2 1]);
printLatexTable(outFile, table2tr, '%0.1f', 'Average number of training instances for single talker', [], {}, colNames);
printLatexTable(outFile, table2te, '%d', 'Total number of test instances for single talker', [], summaryRowNames, [{''} colNames]);

%isSig = significantBinomial(table2, table2te);
%printLatexTable(outFile, table2, '%0.1f', 'Cross validation accuracy for single talker', isSig);

% train 2, test 1, different talker
[t2t1DiffAcc t2t1DiffAccDiffWord] = loadAcc(diffTalkerInds, 'trainSvmOnAllButOne');
table3 = [permute(mean(t2t1DiffAcc,1), [3 2 1]);
    permute(mean(t2t1DiffAccDiffWord,1), [3 2 1]);
    mean(xvalAcc(3:6,:,1),1)];
printLatexTable(outFile, table3, '%0.1f', 'Cross-utterance accuracy for different talkers', [], summaryRowNames, [{''} colNames]);

[t2t1DiffNTe t2t1DiffNTeDiffWord t2t1DiffNTr] = loadTtNumTest(diffTalkerInds, 'trainSvmOnAllButOne');
table3te = [permute(sum(t2t1DiffNTe, 1), [3 2 1]);
    permute(sum(t2t1DiffNTeDiffWord, 1), [3 2 1]);
    sum(nTe(3:6,:,1),1)];
table3tr = permute(mean(t2t1DiffNTr, 1), [3 2 1]);
printLatexTable(outFile, table3tr, '%0.1f', 'Average number of training instances for different talkers', [], {}, colNames);
printLatexTable(outFile, table3te, '%d', 'Total number of test instances for different talkers', [], summaryRowNames, [{''} colNames]);

%isSig = significantBinomial(table3, table3te);
%printLatexTable(outFile, table3, '%0.1f', 'Cross validation accuracy for different talkers', isSig);

% Warped per-utterance cross-utterance results
table4 = [t2t1SameAcc; t2t1DiffAcc];
table4 = [table4; mean(table4,1)];
table4te = [t2t1SameNTe; t2t1DiffNTe];
table4te = [table4te; sum(table4te,1)];
isSig = significantBinomial(table4, table4te);
printLatexTable(outFile, table4(:,:,1), '%0.1f', 'Cross-utterance accuracy without warping tested on each utterance', isSig(:,:,1), [longTalkerIds {'Avg'}], colNames);
printLatexTable(outFile, table4(:,:,2), '%0.1f', 'Cross-utterance accuracy with warping tested on each utterance', isSig(:,:,2), [longTalkerIds {'Avg'}], colNames);

isSig = compareProportions(table4(:,:,2)/100, table4(:,:,1)/100, table4te(:,:,2), table4te(:,:,1));
printLatexTable(outFile, table4(:,:,2) - table4(:,:,1), '%0.2f', 'Cross utterance accuracy delta from warping', isSig, [longTalkerIds {'Avg'}], colNames);

isSig = compareProportions(table4([1:5 7 8],:,2)/100, xvalAcc(:,:,1)/100, table4te([1:5 7 8],:,2), nTe(:,:,1));
printLatexTable(outFile, table4([1:5 7 8],:,2) - xvalAcc(:,:,1), '%0.2f', 'Cross utterance accuracy with warping - cross-validation accuracy', isSig, [talkerIds {'Avg'}], colNames);


[table5 isSig] = compareSameDiff(t2t1SameAcc, t2t1SameAccDiffWord, t2t1DiffAcc, t2t1DiffAccDiffWord, t2t1SameNTe, t2t1SameNTeDiffWord, t2t1DiffNTe, t2t1DiffNTeDiffWord);
printLatexTable(outFile, table5(:,:,2), '%0.1f', 'Various cross-utterance tests', isSig(:,:,2), {'ST SW', 'ST DW', 'DT SW', 'DT DW', 'ST $\Delta$W', 'DT $\Delta$W', 'SW $\Delta$T', 'DW $\Delta$T'}, colNames);

[limNTrSTSW limNTrSTDW] = loadAcc(sameTalkerInds, 'trainSvmOnAllButOneLimNtr');
[limNTrDTSW limNTrDTDW] = loadAcc(diffTalkerInds, 'trainSvmOnAllButOneLimNtr');
[limNTrSTSWnTe limNTrSTDWnTe limNTrSTSWnTr] = loadTtNumTest(sameTalkerInds, 'trainSvmOnAllButOneLimNtr');
[limNTrDTSWnTe limNTrDTDWnTe limNTrDTSWnTr] = loadTtNumTest(diffTalkerInds, 'trainSvmOnAllButOneLimNtr');
table6 = [mean(mean(t2t1SameNTr,1),2) mean(t2t1SameAcc,1);
    mean(mean(limNTrSTSWnTr,1),2) mean(limNTrSTSW,1);
    mean(mean(nTr(sameTalkersInTables,:,[1 1]),1),2) mean(xvalAcc(sameTalkersInTables,:,[1 1]));
    mean(mean(t2t1DiffNTr,1),2) mean(t2t1DiffAcc,1);
    mean(mean(limNTrDTSWnTr,1),2) mean(limNTrDTSW,1);
    mean(mean(nTr(diffTalkersInTables,:,[1 1]),1),2) mean(xvalAcc(diffTalkersInTables,:,[1 1]))];
table6te = [sum(t2t1SameNTe,1);
    sum(limNTrSTSWnTe,1);
    sum(nTe(sameTalkersInTables,:,[1 1]));
    sum(t2t1DiffNTe,1);
    sum(limNTrDTSWnTe,1);
    sum(nTe(diffTalkersInTables,:,[1 1]))];
isSig = [zeros(size(table6te,1),1) significantBinomial(table6(:,2:end,2), table6te(:,:,2))];
printLatexTable(outFile, table6(:,:,2), '%0.1f', 'Limiting cross-utterance training data to the same as cross-validation', isSig, {'S & D', 'S & D', 'S & S', 'D & D', 'D & D', 'D & S'}, colNames);


%%
plot(nTr(:,:,1), xvalAcc(:,:,1), '.')
xlabel('Number of training points')
ylabel('Cross-validation accuracy (%)')
legend(colNames);
prt('xval_vs_ntr')

plot(xvalAcc(:,:,1), table4([1:5 7 8],:,2), '.', [50 90], [50 90])
xlabel('Cross-validation accuracy (%)')
ylabel('Warped cross-utterance accuracy (%)')
legend(colNames);
prt('warped_vs_xval')

plot(table4(:,:,1), table4(:,:,2), '.', [50 90], [50 90])
xlabel('Un-warped cross-utterance accuracy (%)')
ylabel('Warped cross-utterance accuracy (%)')
legend(colNames);
prt('warped_vs_unwarped')


%%
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

function [isSig pVal] = compareProportions(p1, p2, n1, n2)
% score test for two proportions. see slide 13 of http://ocw.jhsph.edu/courses/methodsinbiostatisticsii/PDFs/lecture18.pdf
% Determine whether p1 is significantly bigger than p2 under a
% normal approximation of a binomial distribution at a 0.05% level. This is
% a two-sided test with the comparison against 0.975.
p = (p1.*n1 + p2.*n2) ./ (n1 + n2);
ts = (p1 - p2) ./ sqrt(p .* (1 - p) .* (1./n1 + 1./n2));
pVal = normcdf(ts);
isSig = (pVal >= 0.975) | (pVal <= 0.025);

function [acc isSig] = compareSameDiff(stsw, stdw, dtsw, dtdw, stswNte, stdwNte, dtswNte, dtdwNte)

acc = [mean(stsw,1); 
    mean(stdw,1); 
    mean(dtsw,1);
    mean(dtdw,1); 
    mean(stsw,1) - mean(stdw,1);
    mean(dtsw,1) - mean(dtdw,1);
    mean(stsw,1) - mean(dtsw,1);
    mean(stdw,1) - mean(dtdw,1)];
isSig = [significantBinomial(mean(stsw,1), sum(stswNte,1)); 
    significantBinomial(mean(stdw,1), sum(stdwNte,1)); 
    significantBinomial(mean(dtsw,1), sum(dtswNte,1)); 
    significantBinomial(mean(dtdw,1), sum(dtdwNte,1)); 
    compareProportions(mean(stsw,1)/100, mean(stdw,1)/100, sum(stswNte,1), sum(stdwNte,1));
    compareProportions(mean(dtsw,1)/100, mean(dtdw,1)/100, sum(dtswNte,1), sum(dtdwNte,1));
    compareProportions(mean(stsw,1)/100, mean(dtsw,1)/100, sum(stswNte,1), sum(dtswNte,1));
    compareProportions(mean(stdw,1)/100, mean(dtdw,1)/100, sum(stdwNte,1), sum(dtdwNte,1))];




function printLatexTable(outFile, X, format, name, B, rowNames, colNames)
if ~exist('format', 'var') || isempty(format), format = '%g'; end
if ~exist('name', 'var') || isempty(name), name = ''; end
if ~exist('B', 'var') || isempty(B), B = zeros(size(X)); end
if ~exist('rowNames', 'var') || isempty(rowNames), rowNames = repmat({''}, size(X,1), 1); end
if ~exist('colNames', 'var') || isempty(colNames), colNames = repmat({''}, 1, size(X,2)); end

f = fopen(outFile, 'a');
fprintf(f, '\n');
fprintf(f, '\\begin{table}\n');
fprintf(f, '\\caption{%s}\n', name);
fprintf(f, '\\begin{center}\n');
fprintf(f, ['\\begin{tabular}{' repmat('c', 1, size(X,2)+2) '}\n']);
fprintf(f, '\\toprule\n');
fprintf(f, '%s \\\\ \n', join([{''} colNames], ' & '));
fprintf(f, '\\midrule\n');
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
    fprintf(f, '%s \\\\ \n', join(row, ' & '));
end
fprintf(f, '\\bottomrule\n');
fprintf(f, '\\end{tabular}\n');
fprintf(f, '\\end{center}\n');
fprintf(f, '\\end{table}\n');
fclose(f);


function path = resFileFor(grouping, doWarp, target, fn)

baseDir = '/home/data/bubblesResults/results3dwBalTr/exp12/trim=30,length=2.2/';
path = fullfile(baseDir, ...
    sprintf('grouping=%d', grouping), ...
    sprintf('doWarp=%d', doWarp), ...
    sprintf('target=%d', target), ...
    sprintf('fn=%s', fn), ...
    'res.mat');
