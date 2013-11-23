function wrap_evalMcrExtensive12()

% Wrapper for evaluation of results from expWarpExtensive

paths = findFiles('C:\Temp\plots\exp12', 'pcaDims*'); 

disp('Cross-validation results')
keep = reMatch(paths, 'xval'); 
str  = pathInfoToStruct(paths(keep));
for w = 1:6
    fprintf('W=%d\n',w)
    [d k] = analyzeResultStruct(str, struct('trim','30'), struct('fn','xvalSvmOnPooled'), struct('fn','xvalSvmOnEachWord','w',num2str(w)), 'mcr'); 
    printResults(d)
end

disp('train/test on separate files results')
keep = reMatch(paths, 'trainSvm'); 
str  = pathInfoToStruct(paths(keep));

disp('Train on 1, test on N-1')
[d k] = analyzeResultStruct(str, struct('trim','30','fn','trainSvmOnOne'), struct('doWarp','1'), struct('doWarp','0'), 'mcr'); printResults(d)

disp('Train on N-1, test on 1')
for i = 2:6
    fprintf('teI=%d\n',i);
    [d k] = analyzeResultStruct(str, struct('trim','30','fn','trainSvmOnAllButOne','teI',num2str(i)), struct('doWarp','1'), struct('doWarp','0'), 'mcr'); 
    printResults(d)
end


function printResults(d)
dmcr = reshape([d.mcr], 36, []);
hist(dmcr), legend('1', '2', '3', '4'), pause
printVec('mean', mean(dmcr,1))
printVec('stddev', std(dmcr,[],1))
[h,p]=ttest(dmcr);
printVec('pVal', p);
printVec('isSig', h);

function printVec(name, vec)
vecStr = sprintf('%g\t', vec);
fprintf('%s\t= [%s]\n', name, vecStr(1:end-1));
