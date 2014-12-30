function [basePcaDir outFeatDir] = extractBubbleFeatures(inDir, outDir, filesOrPattern, pcaDims, trimFrames, setLength_s, noiseShape, overwrite)

% Extract features from all bubble mixtures
%
% extractBubbleFeatures(inDir, outDir, filesOrPattern, pcaDims, trimFrames, setLength_s, noiseShape, overwrite)
%
% Extracts bubble features, computes PCA on those features, and then also
% saves a dimensionality-reduced version of each feature using that PCA.
%
% Inputs:
%   inDir           directory to read mixtures from
%   outDir          base directory to write files to (in directories
%                   containing info on trim and length)
%   filesOrPattern  list of files or pattern to find in inDir
%   pcaDims         [dims files] pair, specifying how many PCA dimensions
%                   to keep from a sampling of that many files
%   trimFrames      number of frames to remove from beginning and end of
%                   spectrograms before performing PCA
%   setLength_s     zero-pad wav files to this length before computing
%                   spectrogram. Set to 0 to leave the length as-is.
%   noiseShape      numeric specifier of noise shape that was passed to
%                   speechProfile() to generate the mixtures
%   overwrite       if 0, do not overwrite existing files, including PCA matrix file  

if ~exist('filesOrPattern', 'var') || isempty(filesOrPattern), filesOrPattern = '.*.wav'; end
if ~exist('pcaDims', 'var') || isempty(pcaDims), pcaDims = [50 200]; end
if ~exist('setLength_s', 'var') || isempty(setLength_s), setLength_s = 0; end
if ~exist('trimFrames', 'var') || isempty(trimFrames), trimFrames = 0; end
if ~exist('noiseShape', 'var') || isempty(noiseShape), noiseShape = 0; end
if ~exist('overwrite', 'var') || isempty(overwrite), overwrite = 0; end

nJobs = 1;
part = [1 1];
ignoreErrors = 0;

trimDir = sprintf('trim=%02d,length=%g', trimFrames, setLength_s);
pcaDir = sprintf('pca_%ddims_%dfiles', pcaDims);
outFeatDir = fullfile(outDir, trimDir, 'feat');
basePcaDir = fullfile(outDir, trimDir, pcaDir);
pcaFile    = fullfile(basePcaDir, 'data.mat');
outPcaDir  = fullfile(basePcaDir, 'feat');

if iscell(filesOrPattern)
    wavFiles = filesOrPattern;
else
    wavFiles = findFiles(inDir, filesOrPattern); 
end
noisyToCleanFn = findNoisyToCleanFn(fullfile(inDir, wavFiles{1}));

disp('Extracting bubble features for every file')
effn =  @(ip,op,f) ef_bubbleFeatures(ip,op, noisyToCleanFn, trimFrames, setLength_s, noiseShape, overwrite);
status = extractFeatures(inDir, outFeatDir, 'mat', wavFiles, ...
    effn, nJobs, part, ignoreErrors, overwrite);

matFiles = regexprep(wavFiles, '.wav$', '.mat');
    
if ~exist(pcaFile, 'file') || overwrite
    disp('Loading files for PCA')
    for f = 1:min(pcaDims(2), length(wavFiles))
        tmp = load(fullfile(outFeatDir, matFiles{f}));
        features(f,:) = single(tmp.features);
        weightVec = tmp.weightVec;
        origShape = tmp.origShape;
    end
    
    disp('Computing PCA across all files')
    mu = mean(features);
    sig = std(features);
    features = bsxfun(@rdivide, bsxfun(@minus, features, mu), sig);
    %[features mu sig] = zscore(features);
    weights = reshape(repmat(weightVec, 1, origShape(2)), 1, size(features, 2));
    pcs = pca(bsxfun(@times, weights, features));
    pcs = pcs(:,1:min(pcaDims(1),end));
    ensureDirExists(pcaFile);
    save(pcaFile, 'pcs', 'mu', 'sig', 'pcaDims', 'origShape', 'weightVec');
else
    load(pcaFile)
end

disp('Augmenting computed features with PCA features')
effn =  @(ip,op,f) ef_pcaFeatures(ip,op, pcs, mu, sig, pcaFile);
status = extractFeatures(outFeatDir, outPcaDir, 'mat', matFiles, ...
    effn, nJobs, part, ignoreErrors, overwrite);



function ef_bubbleFeatures(ip, op, noisyToCleanFn, trimFrames, setLength_s, noiseShape, overwrite)

cleanWavFile = noisyToCleanFn(ip);
cleanMatFile = noisyToCleanFn(op);

[clean fs nfft] = loadSpecgramBubbleFeats(cleanWavFile, setLength_s);
[mix   fs nfft] = loadSpecgramBubbleFeats(ip, setLength_s);
[features origShape weights cleanFeat weightVec] = ...
    bubbleFeatures(clean, mix, fs, nfft, noiseShape, trimFrames);

if ~exist(cleanMatFile, 'file') || overwrite
    ensureDirExists(cleanMatFile)
    save(cleanMatFile, 'cleanFeat', 'origShape', 'fs', 'nfft', 'trimFrames', 'weightVec', 'noiseShape');
end
save(op, 'features', 'weightVec', 'origShape', 'fs', 'nfft', 'trimFrames', 'noiseShape')


function ef_pcaFeatures(ip, op, pcs, mu, sig, pcaFile)
load(ip)
weights = reshape(repmat(weightVec, 1, origShape(2)), size(features));
features = bsxfun(@times, bsxfun(@minus, features, mu), weights ./ sig);
pcaFeat = features * pcs;
save(op, 'pcaFeat', 'origShape', 'weightVec', 'fs', 'nfft', ...
    'trimFrames', 'noiseShape', 'pcaFile');
