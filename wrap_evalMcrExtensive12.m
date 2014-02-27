function wrap_evalMcrExtensive12(toDisk, startAt)

% Wrapper for evaluation of results from expWarpExtensive

if ~exist('toDisk', 'var') || isempty(toDisk), toDisk = false; end
if ~exist('startAt', 'var') || isempty(startAt), startAt = 0; end
prt('ToFile', toDisk, 'StartAt', startAt, ...
    'Width', 4, 'Height', 3, 'FormatLine', 'png', ...
    'TargetDir', 'z:\data\plots\evalMcrExtensive12\', ...
    'SaveTicks', 1, 'Resolution', 200)

paths = findFiles('C:\Temp\plots\exp12', 'pcaDims*'); 

keep = reMatch(paths, 'xval'); 
str  = pathInfoToStruct(paths(keep));
disp('Cross-validation results, grouping=0')
clear mu sig pVal isSig
for w = 1:3
    [d k] = analyzeResultStruct(str, struct('trim','30','grouping','0'), struct('fn','xvalSvmOnPooled'), struct('fn','xvalSvmOnEachWord','w',num2str(w)), 'mcr'); 
    [mu(:,w) sig(:,w) pVal(:,w) isSig(:,w)] = printResults(d, 36);
end
plotResults(mu, sig, pVal, isSig, 'Cross-validation accuracy, pooled - individual words, within exp', 'Word in set', {'not warped', 'warped'})

disp('Cross-validation results, grouping=1')
clear mu sig pVal isSig
for w = 1:6
    [d k] = analyzeResultStruct(str, struct('trim','30','grouping','1'), struct('fn','xvalSvmOnPooled'), struct('fn','xvalSvmOnEachWord','w',num2str(w)), 'mcr'); 
    [mu(:,w) sig(:,w) pVal(:,w) isSig(:,w)] = printResults(d, 36);
end
plotResults(mu, sig, pVal, isSig, 'Cross-validation accuracy, pooled - individual words, across exp', 'Word in set', {'not warped', 'warped'})

disp('train/test on separate files results')
keep = reMatch(paths, 'trainSvm'); 
str  = pathInfoToStruct(paths(keep));

disp('Train on 1, test on N-1')
clear mu sig pVal isSig
[d k] = analyzeResultStruct(str, struct('trim','30','fn','trainSvmOnOne'), struct('doWarp','1'), struct('doWarp','0'), 'mcr'); 
[mu sig pVal isSig] = printResults(d, 36);
plotResults(mu(:,[1 1]), sig(:,[1 1]), pVal(:,[1 1]), isSig(:,[1 1]), 'Train on 1 test on N-1, warped - not warped', '[dummy]', {'within exp', 'across exp'})

disp('Train on N-1, test on 1')
clear mu sig pVal isSig
for w = 1:6
    [d k] = analyzeResultStruct(str, struct('trim','30','fn','trainSvmOnAllButOne','teI',num2str(w)), struct('doWarp','1'), struct('doWarp','0'), 'mcr'); 
    [mu(:,w) sig(:,w) pVal(:,w) isSig(:,w)] = printResults(d, 36);
end
mu(1,4:6) = nan; sig(1,4:6) = nan; pVal(1,4:6) = nan; isSig(1,4:6) = nan;
plotResults(mu, sig, pVal, isSig, 'Train on N-1 test on 1, warped - not warped', 'Word in set', {'within exp', 'across exp'})

disp('Compare warping for each grouping and each word')
clear mu sig pVal isSig
for w = 1:36
    [d k] = analyzeResultStruct(str, struct('trim','30','fn','trainSvmOnAllButOne','target',num2str(w)), struct('doWarp','1'), struct('doWarp','0'), 'mcr');
    [mu(:,w) sig(:,w) pVal(:,w) isSig(:,w)] = printResults(d, [3 6]);
end
plotResults(mu, sig, pVal, isSig, 'Each word, warped - not warped', 'Word', {'within exp', 'across exp'})


% disp('Compare grouping for each warping and each word')
% for i = 1:36
%     fprintf('Word=%d\n',i)
%     [d k] = analyzeResultStruct(str, struct('trim','30','fn','trainSvmOnAllButOne','target',num2str(i)), struct('grouping','1'), struct('grouping','0'), 'mcr');
%     printResults(d, [3 5])
% end


function [mu sig pVal isSig] = printResults(d, groupSizes)
doPlot = 0;
if length(groupSizes) == 1
    groupSizes = groupSizes * ones(1, length(d) / groupSizes);
end
groupEnds = [0 cumsum(groupSizes)];
for g = 1:length(groupEnds)-1
    dmcr = cat(1, d(groupEnds(g)+1:groupEnds(g+1)).mcr);
    if doPlot
        [h x] = hist(dmcr);
        plot(x,h)
        legend('1', '2', '3', '4')
        pause
    end
    mu(g,:)  = mean(dmcr,1);
    sig(g,:) = std(dmcr,[],1);
    [isSig(g,:) pVal(g,:)] = ttest(dmcr);

    if nargout == 0
        printVec('mean', mu(g,:))
        printVec('stddev', sig(g,:))
        printVec('pVal', pVal(g,:));
        printVec('isSig', isSig(g,:));
    end
end

function printVec(name, vec)
vecStr = sprintf('%g\t', vec);
fprintf('%s\t= [%s]\n', name, vecStr(1:end-1));

function plotResults(mu, sig, pVal, isSig, plotName, xLab, rowNames)
staggeredErrorbar(mu', sig', isSig')
title(plotName)
legend(rowNames)
ylabel('\Delta error (percentage points, lower is better)')
xlabel(xLab)
prt(plotName)

function staggeredErrorbar(y, e, isSig)
[c r] = meshgrid(1:size(y,2), 1:size(y,1));
x = r + 0.1 * zscore(c,0,2);
errorbar(x, y, e);
colOrd = get(gca,'ColorOrder');
nCol = size(colOrd,2);
hold on
plot([min(x(:)) max(x(:))], [0 0], '--k')
for i = 1:size(x,2)
    colRow = rem(i-1,nCol)+1;
    col = colOrd(colRow,:);
    sig = find(isSig(:,i));
    plot(x(sig,i), y(sig,i), '*', 'Color', col)
end
hold off
