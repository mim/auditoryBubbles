function wrap_evalMcrExtensive12()

% Wrapper for evaluation of results from expWarpExtensive

paths = findFiles('C:\Temp\plots\exp12', 'pcaDims*'); 

disp('Cross-validation results')
keep = reMatch(paths, 'xval'); 
str  = pathInfoToStruct(paths(keep));
for w = 1:6
    fprintf('W=%d\n',w)
    [d k] = analyzeResultStruct(str, struct('trim','30'), struct('fn','xvalSvmOnPooled'), struct('fn','xvalSvmOnEachWord','w',num2str(w)), 'mcr'); 
    [mu sig] = printResults(d, 36);
end

disp('train/test on separate files results')
keep = reMatch(paths, 'trainSvm'); 
str  = pathInfoToStruct(paths(keep));

disp('Train on 1, test on N-1')
[d k] = analyzeResultStruct(str, struct('trim','30','fn','trainSvmOnOne'), struct('doWarp','1'), struct('doWarp','0'), 'mcr'); 
printResults(d, 36)

disp('Train on N-1, test on 1')
for i = 2:6
    fprintf('teI=%d\n',i);
    [d k] = analyzeResultStruct(str, struct('trim','30','fn','trainSvmOnAllButOne','teI',num2str(i)), struct('doWarp','1'), struct('doWarp','0'), 'mcr'); 
    [mu sig] = printResults(d, 36);
end

disp('Compare warping for each grouping and each word')
for i = 1:36
    fprintf('Word=%d\n',i)
    [d k] = analyzeResultStruct(str, struct('trim','30','fn','trainSvmOnAllButOne','target',num2str(i)), struct('doWarp','1'), struct('doWarp','0'), 'mcr');
    [mu sig] = printResults(d, [3 6]);
end

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
