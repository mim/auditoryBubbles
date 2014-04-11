function expWarpExtensiveFromCache(expNum, trimDir, pcaDims)

% Run lots of experiments on warped bubble noise data

if ~exist('pcaDims', 'var') || isempty(pcaDims), pcaDims = 70; end
if ~exist('trimDir', 'var') || isempty(trimDir), trimDir = 'trim=30,length=2.2'; end
if ~exist('expNum', 'var') || isempty(expNum), expNum = 12; end

expDir  = sprintf('exp%d', expNum); 
outDir  = fullfile('C:\Temp\data\resultsPbcBalTr', expDir, trimDir);
inDir   = fullfile('C:\Temp\data\tfctAndPcaPbc', expDir, trimDir);

fns = {
    @trainSvmOnOne, ...
    @trainSvmOnAllButOne, ...
    @trainSvmOnAllButOneLimNtr, ...
    @xvalSvmOnEachWord, ...
    @xvalSvmOnPooled ...
    };

%for grouping = 1
for grouping = 0
    for doWarp = [1 0]
        for target = [5:6:36 2:6:36]
            inFile = dataFileFor(inDir, grouping, doWarp, target);
            fprintf('Loading %s\n', inFile);
            d = load(inFile);

            partialOutDir = gwtDirFor(outDir, grouping, doWarp, target);
            tfctOutDir = fullfile(partialOutDir, 'fn=plotTfctWrapper');
            ensureDirExists(tfctOutDir, 1);
            plotTfctWrapper(tfctOutDir, d.s0, d.s1, d.sNot0, d.sNot1, d.clean, d.origShape, d.numDiffWords)
            
            pbcOutDir = fullfile(partialOutDir, 'fn=plotPbc');
            ensureDirExists(pbcOutDir, 1);
            plotPbc(pbcOutDir, d.s0, d.s1, d.n0, d.n1, d.sig, d.origShape, d.numDiffWords)
            
            for f = 1:length(fns)
                fullOutDir = fullfile(partialOutDir, sprintf('fn=%s',func2str(fns{f})));
                ensureDirExists(fullOutDir, 1);
                fns{f}(fullOutDir, d.Xte, d.yte, pcaDims, d.numDiffWords);
            end
        end
    end
end

function path = dataFileFor(baseDir, grouping, doWarp, target)
path = fullfile(gwtDirFor(baseDir, grouping, doWarp, target), 'tfctAndPca.mat');

function path = gwtDirFor(baseDir, grouping, doWarp, target)
path = fullfile(baseDir, ...
    sprintf('grouping=%d', grouping), ...
    sprintf('doWarp=%d', doWarp), ...
    sprintf('target=%d', target));

function plotTfctWrapper(outDir,s0,s1,sNot0,sNot1,clean,origShape,numDiffWords)
for w = 1:size(s0,1)
    mat(:,:,w) = plotableTfct(sNot0(w,:), sNot1(w,:), s0(w,:), s1(w,:), origShape);
end

nSame = size(s0,1) - numDiffWords;
rs0 = sum(s0(1:nSame,:), 1);
rs1 = sum(s1(1:nSame,:), 1);
rsNot0 = sum(sNot0(1:nSame,:), 1);
rsNot1 = sum(sNot1(1:nSame,:), 1);

mat(:,:,w+1) = plotableTfct(rsNot0, rsNot1, rs0, rs1, origShape);
clean = cat(3, clean{:});
save(fullfile(outDir, 'res'), 'mat', 'clean', 'rs0', 'rs1', 'rsNot0', 'rsNot1', 'numDiffWords');

function mat = plotableTfct(sNot0, sNot1, s0, s1, origShape)
[~,p,isHigh] = tfCrossTab(sNot0, sNot1, s0, s1);
mat = reshape((2*isHigh-1).*exp(-p/0.05), origShape);

function plotPbc(outDir, s0, s1, n0, n1, sig, origShape, numDiffWords)
[tpbc tpval tvis] = pointBiserialCorr(s0, s1, n0, n1, sig);
W = size(s0,1);
pbc  = reshape(tpbc, [origShape W]);
pval = reshape(tpval, [origShape W]);
vis  = reshape(tvis, [origShape W]);
save(fullfile(outDir, 'res'), 'pbc', 'pval', 'vis', 'origShape', 'numDiffWords');


function trainSvmOnOne(outDir,Xs,ys,pcaDims,numDiffWords)
Xtr = Xs{1};
ytr = ys{1};
Xte = cat(1, Xs{2:end});
yte = cat(1, ys{2:end});
[mcr mcrBal nTe nTr nTeBal] = svmTrainTest(Xtr, ytr, Xte, yte, pcaDims, [], false);
touch(fullfile(outDir, sprintf('pcaDims=%d,mcr=%.04f', pcaDims, mcr)));
save(fullfile(outDir, 'res'), 'mcr', 'mcrBal', 'nTe', 'nTr', 'nTeBal', 'pcaDims', 'numDiffWords', 'outDir');

function trainSvmOnAllButOneLimNtr(outDir,Xs,ys,pcaDims,numDiffWords)
trainSvmOnAllButOne(outDir,Xs,ys,pcaDims,numDiffWords,0.8)

function trainSvmOnAllButOne(outDir,Xs,ys,pcaDims,numDiffWords,limitNTrPct)
if ~exist('limitNTrPct', 'var') || isempty(limitNTrPct), limitNTrPct = -1; end
XteDw = cat(1, Xs{end-numDiffWords+1:end});
yteDw = cat(1, ys{end-numDiffWords+1:end});
for w=1:length(Xs)-numDiffWords
    tr = setdiff(1:length(Xs)-numDiffWords, w);
    Xtr = cat(1, Xs{tr});
    ytr = cat(1, ys{tr});
    Xte = [Xs{w}; XteDw];
    yte = [ys{w}; yteDw];
    
    if limitNTrPct > 0
        limNTr = ceil(limitNTrPct * length(balanceSets(ys{w}, false)));
        keepAllTr = false;
    else
        limNTr = inf;
        keepAllTr = false;
    end
    
    teGroup = [ones(size(ys{w})); 2*ones(size(yteDw))];
    [mcr(w,:) mcrBal(w,:) nTe(w,:,:) nTr(w,:) nTeBal(w,:,:)] = svmTrainTest(Xtr, ytr, Xte, yte, pcaDims, teGroup, keepAllTr, limNTr);
    touch(fullfile(outDir, sprintf('pcaDims=%d,teI=%d,mcr=%.04f', pcaDims, w, mcr(w,1))));
end
save(fullfile(outDir, 'res'), 'mcr', 'mcrBal', 'nTe', 'nTr', 'nTeBal', 'pcaDims', 'numDiffWords', 'outDir');

function xvalSvmOnEachWord(outDir,Xte,yte,pcaDims,numDiffWords)
for w = 1:length(Xte)
    [mcr(w,1) data(w,1)] = svmXVal(Xte{w}, yte{w}, pcaDims);
    touch(fullfile(outDir, sprintf('pcaDims=%d,w=%d,mcr=%.04f',pcaDims,w,mcr(w))));
end
save(fullfile(outDir, 'res'), 'mcr', 'data', 'pcaDims', 'numDiffWords', 'outDir')

function xvalSvmOnPooled(outDir,Xte,yte,pcaDims,numDiffWords)
[mcr data] = svmXVal(cat(1, Xte{1:end-numDiffWords}), cat(1, yte{1:end-numDiffWords}), pcaDims);
[mcrAll dataAll] = svmXVal(cat(1, Xte{:}), cat(1, yte{:}), pcaDims);
touch(fullfile(outDir, sprintf('pcaDims=%d,mcr=%.04f',pcaDims,mcr)));
save(fullfile(outDir, 'res'), 'mcr', 'data', 'mcrAll', 'dataAll', 'pcaDims', 'numDiffWords', 'outDir')

function touch(filePath)
f = fopen(filePath, 'w');
fclose(f);
