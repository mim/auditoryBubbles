function wrap_evalMcrExtensive()

% Wrapper for evaluation of results from expWarpExtensive

paths = findFiles('C:\Temp\plots\', 'pcaDims*'); 

disp('Cross-validation results')
keep = reMatch(paths, 'xval'); 
str  = pathInfoToStruct(paths(keep));
disp('W=1'), [d k] = analyzeResultStruct(str, struct('trim','30'), struct('fn','xvalSvmOnPooled','w','3'), struct('fn','xvalSvmOnEachWord','w','1'), 'mcr'); printResults(d)
disp('W=2'), [d k] = analyzeResultStruct(str, struct('trim','30'), struct('fn','xvalSvmOnPooled','w','3'), struct('fn','xvalSvmOnEachWord','w','2'), 'mcr'); printResults(d)
disp('W=3'), [d k] = analyzeResultStruct(str, struct('trim','30'), struct('fn','xvalSvmOnPooled','w','3'), struct('fn','xvalSvmOnEachWord','w','3'), 'mcr'); printResults(d)

disp('train/test on separate files results')
keep = reMatch(paths, 'trainSvm'); 
str  = pathInfoToStruct(paths(keep));

disp('Train on 1, test on 2')
[d k] = analyzeResultStruct(str, struct('trim','30','fn','trainSvmOnTargetTestOnOtherTwo'), struct('doWarp','1'), struct('doWarp','0'), 'mcr'); printResults(d)

disp('Train on 2, test on 1')
disp('trI=2'), [d k] = analyzeResultStruct(str, struct('trim','30','fn','trainSvmOnTargetAndEachWarpedTestOnOther','trI','2'), struct('doWarp','1'), struct('doWarp','0'), 'mcr'); printResults(d)
disp('trI=3'), [d k] = analyzeResultStruct(str, struct('trim','30','fn','trainSvmOnTargetAndEachWarpedTestOnOther','trI','3'), struct('doWarp','1'), struct('doWarp','0'), 'mcr'); printResults(d)


function printResults(d)
dmcr = reshape([d.mcr], 18, []);
printVec('mean', mean(dmcr,1))
printVec('stddev', std(dmcr,[],1))
[h,p]=ttest(dmcr);
printVec('pVal', p);
printVec('isSig', h);

function printVec(name, vec)
vecStr = sprintf('%g\t', vec);
fprintf('%s\t= [%s]\n', name, vecStr(1:end-1));
