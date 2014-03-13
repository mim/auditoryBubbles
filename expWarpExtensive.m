function expWarpExtensive(expNum, trimDir, pcaDims)

% Run lots of experiments on warped bubble noise data

if ~exist('pcaDims', 'var') || isempty(pcaDims), pcaDims = 70; end
if ~exist('trimDir', 'var') || isempty(trimDir), trimDir = 'trim=30,length=2.2'; end
if ~exist('expNum', 'var') || isempty(expNum), expNum = 12; end

seed = 22;
numDiffWords = 0;

expDir  = sprintf('exp%d', expNum); 
outDir      = fullfile('C:\Temp\plots\', expDir, trimDir);
baseDir     = fullfile('C:\Temp\mrtFeatures\shannonLight\', expDir, trimDir);
pcaDataFile = 'pcaData_100dims_1000files.mat';
groupedFile = fullfile('D:\Box Sync\data\mrt\shannonResults', sprintf('groupedExp%dTmp.mat', expNum));
cleanFiles  = findFiles(baseDir, 'bpsInf');
pcaFiles    = findFiles(baseDir, 'snr-35_.mat');

fns = {
    @plotTfctWrapper ... ,
    @trainSvmOnOne, ...
    @trainSvmOnAllButOne, ...
    @xvalSvmOnEachWord, ...
    @xvalSvmOnPooled ...
    };

%for grouping = 1
for grouping = 0
    for doWarp = [1 0]
        for target = [1:6:length(pcaFiles) 2:6:length(pcaFiles)]
            [sameWord,~,~,diffWord] = sameWordFor(target, pcaFiles, grouping);
            diffWordInds = runWithRandomSeed(seed, @() randperm(length(diffWord)));
            words = [sameWord diffWord(diffWordInds(1:numDiffWords))];
            
            clear Xte yte warped clean warpDist mfccDist startDist
            for c = 1:length(words),
                [~,~,Xte{c},yte{c},warped{c},~,origShape,clean{c},warpDist(c),mfccDist(c),startDist(c)] = ...
                    crossUtWarp(baseDir, pcaFiles{target}, cleanFiles{words(c)}, pcaDataFile, groupedFile, doWarp);
            end
            partialOutDir = fullfile(outDir, sprintf('grouping=%d', grouping), ...
                sprintf('doWarp=%d', doWarp), sprintf('target=%d',target));
            warpDistFile = fullfile(partialOutDir, 'warpDist.mat');
            ensureDirExists(warpDistFile);
            save(warpDistFile, 'warpDist', 'mfccDist', 'startDist');
            
            for f = 1:length(fns)
                fullOutDir = fullfile(partialOutDir, sprintf('fn=%s',func2str(fns{f})));
                ensureDirExists(fullOutDir, 1);
                fns{f}(fullOutDir,Xte,yte,warped,clean,origShape,pcaDims,numDiffWords);
            end
        end
    end
end


function plotTfctWrapper(outDir,Xte,yte,warped,clean,origShape,pcaDims,numDiffWords)
rs0 = 0; rs1 = 0; rsNot0 = 0; rsNot1 = 0;
for w = 1:length(yte)
    feat0 = warped{w}(yte{w}<0,:);
    feat1 = warped{w}(yte{w}>0,:);
    s0 = sum(feat0);
    s1 = sum(feat1);
    sNot0 = size(feat0,1) - s0;
    sNot1 = size(feat1,1) - s1;

    mat(:,:,w) = plotTfct(fullfile(outDir, sprintf('word%d', w)), sNot0, sNot1, s0, s1, clean{w}, origShape);

    if w <= length(yte) - numDiffWords
        rs0 = rs0 + s0;
        rs1 = rs1 + s1;
        rsNot0 = rsNot0 + sNot0;
        rsNot1 = rsNot1 + sNot1;
    end
end
mat(:,:,w+1) = plotTfct(fullfile(outDir, 'combined'), rsNot0, rsNot1, rs0, rs1, clean{1}, origShape);
clean = cat(3, clean{:});
save(fullfile(outDir, 'res'), 'mat', 'clean', 'rs0', 'rs1', 'rsNot0', 'rsNot1');

function mat = plotTfct(outFile, sNot0, sNot1, s0, s1, clean, origShape)
[~,p,isHigh] = tfCrossTab(sNot0, sNot1, s0, s1);
mat = reshape((2*isHigh-1).*exp(-p/0.05), origShape);
subplots(mat)
print('-dpng', outFile);

subplots(clean)
print('-dpng', [outFile '_spec'])

%noiseLevel = min(clean(:));  % not important -> min(clean) dB
noiseLevel = max(clean(:));  % not important -> max(clean) dB
selected = (clean - noiseLevel) .* (mat .* (mat > 0)) + noiseLevel;  

subplots(selected)
print('-dpng', [outFile '_onSpec'])


function trainSvmOnOne(outDir,Xs,ys,warped,clean,origShape,pcaDims,numDiffWords)
Xtr = Xs{1};
ytr = ys{1};
Xte = cat(1, Xs{2:end});
yte = cat(1, ys{2:end});
[mcr mcrBal nTe nTr nTeBal] = svmTrainTest(Xtr, ytr, Xte, yte, pcaDims);
touch(fullfile(outDir, sprintf('pcaDims=%d,mcr=%.04f', pcaDims, mcr)));
save(fullfile(outDir, 'res'), 'mcr', 'mcrBal', 'nTe', 'nTr', 'nTeBal', 'pcaDims', 'outDir');

function trainSvmOnAllButOne(outDir,Xs,ys,warped,clean,origShape,pcaDims,numDiffWords)
for i=1:length(Xs)-numDiffWords
    tr = setdiff(1:length(Xs)-numDiffWords, i);
    Xtr = cat(1, Xs{tr});
    ytr = cat(1, ys{tr});
    Xte = Xs{i};
    yte = ys{i};
    [mcr(i) mcrBal(i) nTe(i,:) nTr(i,:) nTeBal(i,:)] = svmTrainTest(Xtr, ytr, Xte, yte, pcaDims);
    touch(fullfile(outDir, sprintf('pcaDims=%d,teI=%d,mcr=%.04f', pcaDims, i, mcr(i))));
end
save(fullfile(outDir, 'res'), 'mcr', 'mcrBal', 'nTe', 'nTr', 'nTeBal', 'pcaDims', 'outDir');

function xvalSvmOnEachWord(outDir,Xte,yte,warped,clean,origShape,pcaDims,numDiffWords)
for w = 1:length(Xte)
    [mcr(w) data(w)] = svmXVal(Xte{w}, yte{w}, pcaDims);
    touch(fullfile(outDir, sprintf('pcaDims=%d,w=%d,mcr=%.04f',pcaDims,w,mcr(w))));
end
save(fullfile(outDir, 'res'), 'mcr', 'data', 'pcaDims', 'outDir')

function xvalSvmOnPooled(outDir,Xte,yte,warped,clean,origShape,pcaDims,numDiffWords)
[mcr data] = svmXVal(cat(1, Xte{1:end-numDiffWords}), cat(1, yte{1:end-numDiffWords}), pcaDims);
[mcrAll dataAll] = svmXVal(cat(1, Xte{:}), cat(1, yte{:}), pcaDims);
touch(fullfile(outDir, sprintf('pcaDims=%d,mcr=%.04f',pcaDims,mcr)));
save(fullfile(outDir, 'res'), 'mcr', 'data', 'mcrAll', 'dataAll', 'pcaDims', 'outDir')

function touch(filePath)
f = fopen(filePath, 'w');
fclose(f);
