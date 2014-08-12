function printConfusionMat(predicted, gt)

% Print a confusion matrix with labels and sums

groupOrder = unique(gt);
[C labels] = confusionmat(predicted, gt, 'order', groupOrder);
crs = num2strCell(sum(C,1));
ccs = num2strCell(sum(C,2));
table = num2strCell(C);
table = [{''} prefixCells(labels', 'Gt:') {'Pr:Sum'};
    prefixCells(labels, 'Pr:') table ccs;
    {'Gt:Sum'} crs {''}];

fieldLengths = cellfun('length', table);
colWidth = max(fieldLengths(:)) + 2;
format = sprintf('%% %ds', colWidth);
for r = 1:size(table,1)
    fprintf(format, table{r,:});
    fprintf('\n');
end


function sc = num2strCell(A)
sc = cellfun(@(x) num2str(x), num2cell(A), 'UniformOutput', false);

function pc = prefixCells(A, prefix)
pc = cellfun(@(x) [prefix x], A, 'UniformOutput', false);
