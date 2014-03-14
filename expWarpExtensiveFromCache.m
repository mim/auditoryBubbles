function expWarpExtensiveFromCache(expNum, trimDir, pcaDims)

% Run lots of experiments on warped bubble noise data

if ~exist('pcaDims', 'var') || isempty(pcaDims), pcaDims = 70; end
if ~exist('trimDir', 'var') || isempty(trimDir), trimDir = 'trim=30,length=2.2'; end
if ~exist('expNum', 'var') || isempty(expNum), expNum = 12; end

expDir  = sprintf('exp%d', expNum); 
outDir  = fullfile('C:\Temp\data\results3dw', expDir, trimDir);
inDir   = fullfile('C:\Temp\data\tfctAndPca3dw', expDir, trimDir);

fns = {
    @trainSvmOnOne, ...
    @trainSvmOnAllButOne, ...
    @xvalSvmOnEachWord, ...
    @xvalSvmOnPooled ...
    };

%for grouping = 1
for grouping = 0
    for doWarp = [1 0]
        for target = [1:6:36 2:6:36]
            inFile = dataFileFor(inDir, grouping, doWarp, target);
            fprintf('Loading %s\n', inFile);
            d = load(inFile);

            partialOutDir = gwtDirFor(outDir, grouping, doWarp, target);
            tfctOutDir = fullfile(partialOutDir, 'fn=plotTfctWrapper');
            ensureDirExists(tfctOutDir, 1);
            plotTfctWrapper(tfctOutDir, d.s0, d.s1, d.sNot0, d.sNot1, d.clean, d.origShape, d.numDiffWords)
            
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
save(fullfile(outDir, 'res'), 'mat', 'clean', 'rs0', 'rs1', 'rsNot0', 'rsNot1');

function mat = plotableTfct(sNot0, sNot1, s0, s1, origShape)
[~,p,isHigh] = tfCrossTab(sNot0, sNot1, s0, s1);
mat = reshape((2*isHigh-1).*exp(-p/0.05), origShape);


function trainSvmOnOne(outDir,Xs,ys,pcaDims,numDiffWords)
Xtr = Xs{1};
ytr = ys{1};
Xte = cat(1, Xs{2:end});
yte = cat(1, ys{2:end});
[mcr mcrBal nTe nTr nTeBal] = svmTrainTest(Xtr, ytr, Xte, yte, pcaDims);
touch(fullfile(outDir, sprintf('pcaDims=%d,mcr=%.04f', pcaDims, mcr)));
save(fullfile(outDir, 'res'), 'mcr', 'mcrBal', 'nTe', 'nTr', 'nTeBal', 'pcaDims', 'numDiffWords', 'outDir');

function trainSvmOnAllButOne(outDir,Xs,ys,pcaDims,numDiffWords)
XteDw = cat(1, Xs{end-numDiffWords+1:end});
yteDw = cat(1, ys{end-numDiffWords+1:end});
for w=1:length(Xs)-numDiffWords
    tr = setdiff(1:length(Xs)-numDiffWords, w);
    Xtr = cat(1, Xs{tr});
    ytr = cat(1, ys{tr});
    Xte = [Xs{w}; XteDw];
    yte = [ys{w}; yteDw];
    teGroup = [ones(size(ys{w})); 2*ones(size(yteDw))];
    [mcr(w,:) mcrBal(w,:) nTe(w,:) nTr(w,:) nTeBal(w,:)] = svmTrainTest(Xtr, ytr, Xte, yte, pcaDims, teGroup);
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
