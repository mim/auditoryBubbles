function expWarpExtensive(expNum, trim, pcaDims)

% Run lots of experiments on warped bubble noise data

if ~exist('pcaDims', 'var') || isempty(pcaDims), pcaDims = 60; end
if ~exist('trim', 'var') || isempty(trim), trim = 10; end
if ~exist('expNum', 'var') || isempty(expNum), expNum = 1; end

expDir  = sprintf('exp%d', expNum); 
trimDir = sprintf('trim%d', trim);
outDir      = fullfile('C:\Temp\plots\', expDir, trimDir);
baseDir     = fullfile('C:\Temp\mrtFeatures\shannonLight\', expDir, trimDir);
pcaDataFile = 'pcaData_100dims_1000files.mat';
groupedFile = fullfile('Z:\data\mrt\shannonResults', sprintf('groupedExp%dTmp.mat', expNum));
cleanFiles  = findFiles(baseDir, 'bpsInf');
pcaFiles    = findFiles(baseDir, 'snr-35_.mat');

fnsForVoicing = {
    { @plotTfctOfEachWord, ...
    @plotTfctOfPooled, ...
    @trainSvmOnTargetTestOnOtherTwo, ...
    @trainSvmOnTargetAndEachWarpedTestOnOther, ...
    @xvalSvmOnEachWord, ...
    @xvalSvmOnPooled }
    { @plotTfctOfPooled }
    };

for iov = [0]
    for doWarp = [0 1]
        for target = 1:length(pcaFiles)
            sameWord = sameWordFor(target, iov);
            for c = 1:length(sameWord),
                [~,~,Xte{c},yte{c},warped{c},~,origShape] = ...
                    crossUtWarp(baseDir, pcaFiles{target}, cleanFiles{sameWord(c)}, pcaDataFile, groupedFile, doWarp);
            end
            
            fns4v = fnsForVoicing{iov+1};
            for f = 1:length(fns4v)
                fullOutDir = fullfile(outDir, sprintf('iov=%d', iov), ...
                    sprintf('doWarp=%d', doWarp), sprintf('target=%d',target), ...
                    sprintf('fn=%s',func2str(fns4v{f})));
                ensureDirExists(fullOutDir, 1);
                fns4v{f}(fullOutDir,Xte,yte,warped,origShape,pcaDims);
            end
        end
    end
end


function plotTfctOfEachWord(outDir,Xte,yte,warped,origShape,pcaDims)
for w = 1:length(yte)
    mat(:,:,w) = plotTfct(fullfile(outDir, sprintf('word%d', w)), warped{w}(yte{w}>0,:), warped{w}(yte{w}<0,:), origShape);
end
save(fullfile(outDir, 'res'), 'mat');

function plotTfctOfPooled(outDir,Xte,yte,warped,origShape,pcaDims)
allW = cat(1,warped{:}); 
allYte = cat(1,yte{:});
mat = plotTfct(fullfile(outDir, 'combined'), allW(allYte>0,:), allW(allYte<0,:), origShape);
save(fullfile(outDir, 'res'), 'mat');

function mat = plotTfct(outFile, feat1, feat0, origShape,pcaDims)
[~,p,isHigh] = tfCrossTab(sum(1-feat0), sum(1-feat1), sum(feat0), sum(feat1));
mat = reshape((2*isHigh-1).*exp(-p/0.05), origShape);
subplots(mat)
print('-dpng', outFile);


function trainSvmOnTargetTestOnOtherTwo(outDir,Xs,ys,warped,origShape,pcaDims)
Xtr = Xs{1};
ytr = ys{1};
Xte = cat(1, Xs{2:end});
yte = cat(1, ys{2:end});
mcr = svmTrainTest(Xtr, ytr, Xte, yte, pcaDims);
touch(fullfile(outDir, sprintf('pcaDims=%d,mcr=%.04f', pcaDims, mcr)));
save(fullfile(outDir, 'res'), 'mcr', 'pcaDims');

function trainSvmOnTargetAndEachWarpedTestOnOther(outDir,Xs,ys,warped,origShape,pcaDims)
for i=2:3
    Xtr = cat(1, Xs{[1 i]});
    ytr = cat(1, ys{[1 i]});
    Xte = Xs{setdiff([2 3], i)};
    yte = ys{setdiff([2 3], i)};
    mcr(i) = svmTrainTest(Xtr, ytr, Xte, yte, pcaDims);
    touch(fullfile(outDir, sprintf('pcaDims=%d,trI=%d,mcr=%.04f', pcaDims, i, mcr(i))));
end
save(fullfile(outDir, 'res'), 'mcr', 'pcaDims');


function xvalSvmOnEachWord(outDir,Xte,yte,warped,origShape,pcaDims)
for w = 1:3
    mcr(w) = svmXVal(Xte{w}, yte{w}, pcaDims);
    touch(fullfile(outDir, sprintf('pcaDims=%d,w=%d,mcr=%.04f',pcaDims,w,mcr(w))));
end
save(fullfile(outDir, 'res'), 'mcr', 'pcaDims')

function xvalSvmOnPooled(outDir,Xte,yte,warped,origShape,pcaDims)
mcr = svmXVal(cat(1, Xte{:}), cat(1, yte{:}), pcaDims);
touch(fullfile(outDir, sprintf('pcaDims=%d,mcr=%.04f',pcaDims,mcr)));
save(fullfile(outDir, 'res'), 'mcr', 'pcaDims')



function words = sameWordFor(target, includeOtherVoicing)
% Target word is always first

wordSet = ceil(target/3);
if includeOtherVoicing
    voicingSet = mod(wordSet-1,3)+1;
    wordSet = voicingSet + [0 3];
end

words = [];
for i = 1:length(wordSet)
    words = [words (wordSet(i)-1)*3+(1:3)];
end

words = [target setdiff(words, target)];


function touch(filePath)
f = fopen(filePath, 'w');
fclose(f);
