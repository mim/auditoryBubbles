function expWarpSimpleFromCache(outDir, inDir, pcaDims)

% Run SVM cross-validation on PCA data and plot TFCT pictures of it.
%
% expWarpSimpleFromCache(outDir, inDir, pcaDims)
%
% Time-frequency cross-tabulation image (TFCT) also known as the
% Time-frequency importance function (TFIF).  Runs SVM cross-validation on
% all of the mixtures involving the same clean utterance, averaging the
% results across all test points in all folds.  If multiple PCA dimensions
% are provided, run nested cross-validation, selecting the best PCA
% dimension within the training set of each fold.  Number of training
% points is balanced between positive and negative classes by randomly
% dropping points from the larger class.  Computes accuracy on both a
% balanced (+/-) test set and the full test set.  Results are written in
% file names in subfolders of outDir and also saved in res.mat files in the
% same subfolders.
%
% Inputs:
%   outDir   Root of directory tree to save pictures and results in
%   inDir    Directory saved to by extractTfctAndPcaSimple()
%   pcaDims  Vector of numbers of PCA dimensions to use in SVM experiment,
%            must be no more than that extracted from them 

[inFiles,inPaths] = findFiles(inDir, 'tfctAndPca.mat');
for i = 1:length(inFiles)
    fprintf('Loading %s\n', inFiles{i});
    d = load(inPaths{i});
    
    partialOutDir = fullfile(outDir, fileparts(inFiles{i}));
    tfctOutDir = fullfile(partialOutDir, 'fn=plotTfctWrapper');
    ensureDirExists(tfctOutDir, 1);
    plotTfctWrapper(tfctOutDir, d.s0, d.s1, d.sNot0, d.sNot1, d.clean, d.origShape)
    
    pbcOutDir = fullfile(partialOutDir, 'fn=plotPbc');
    ensureDirExists(pbcOutDir, 1);
    plotPbc(pbcOutDir, d.s0, d.s1, d.n0, d.n1, d.sig, d.origShape)
    
    svmOutDir = fullfile(partialOutDir, 'fn=xvalSvmOnEachWord');
    ensureDirExists(svmOutDir, 1);
    xvalSvmOnEachWord(svmOutDir, d.Xte, d.yte, pcaDims);
end


function plotTfctWrapper(outDir,s0,s1,sNot0,sNot1,clean,origShape)
for w = 1:size(s0,1)
    mat(:,:,w) = plotableTfct(sNot0(w,:), sNot1(w,:), s0(w,:), s1(w,:), origShape);
end

nSame = size(s0,1);
rs0 = sum(s0(1:nSame,:), 1);
rs1 = sum(s1(1:nSame,:), 1);
rsNot0 = sum(sNot0(1:nSame,:), 1);
rsNot1 = sum(sNot1(1:nSame,:), 1);

if w > 1
    mat(:,:,w+1) = plotableTfct(rsNot0, rsNot1, rs0, rs1, origShape);
end
save(fullfile(outDir, 'res'), 'mat', 'clean', 'rs0', 'rs1', 'rsNot0', 'rsNot1');

function mat = plotableTfct(sNot0, sNot1, s0, s1, origShape)
[~,p,isHigh] = tfCrossTab(sNot0, sNot1, s0, s1);
mat = reshape((2*isHigh-1).*exp(-p/0.05), origShape);

function plotPbc(outDir, s0, s1, n0, n1, sig, origShape)
[tpbc tpval tvis] = pointBiserialCorr(s0, s1, n0, n1, sig);
W = size(s0,1);
pbc  = reshape(tpbc, [origShape W]);
pval = reshape(tpval, [origShape W]);
vis  = reshape(tvis, [origShape W]);
save(fullfile(outDir, 'res'), 'pbc', 'pval', 'vis', 'origShape');

function xvalSvmOnEachWord(outDir,Xte,yte,pcaDims)
[mcr data] = svmXVal(Xte, yte, pcaDims);
touch(fullfile(outDir, sprintf('pcaDims=%d,mcr=%.04f',pcaDims,mcr)));
save(fullfile(outDir, 'res'), 'mcr', 'data', 'pcaDims', 'outDir')

function touch(filePath)
f = fopen(filePath, 'w');
fclose(f);
