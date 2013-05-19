function updatePcaFeat(inDir, outDir, filePattern)
    
% Convert PCA features extracted by collectFeatures to have
% whitened pcaFeat instead of whitened pcs
    
if ~exist('filePattern', 'var') || isempty(filePattern), filePattern = '.*.mat'; end
    
if strcmp(inDir, outDir)
    error('Same input and output directories')
end
    
[files,paths] = findFiles(inDir, filePattern);

for i = 1:length(paths)
    outFile = fullfile(outDir, files{i});
    fprintf('%d: %s\n', i, outFile);
    
    m = load(paths{i});
    [m.pcaFeat m.pcs] = pca(bsxfun(@times, m.weights, zscore(m.features))');
    
    ensureDirExists(outFile)
    save('-v6', outFile, '-struct', 'm');
end
