function extractBubbleFeatures(inDir, outDir, filesOrPattern, pcaDims, trimFrames, setLength_s, oldProfile, overwrite)

% Similar to collectFeatures, but parallizeable using extractFeatures.m

if ~exist('filesOrPattern', 'var') || isempty(filesOrPattern), filesOrPattern = '.*.wav'; end
if ~exist('pcaDims', 'var') || isempty(pcaDims), pcaDims = [50 200]; end
if ~exist('setLength_s', 'var') || isempty(setLength_s), setLength_s = 0; end
if ~exist('trimFrames', 'var') || isempty(trimFrames), trimFrames = 0; end
if ~exist('oldProfile', 'var') || isempty(oldProfile), oldProfile = 0; end
if ~exist('overwrite', 'var') || isempty(overwrite), overwrite = 0; end

nJobs = 1;
part = [1 1];
ignoreErrors = 0;

trimDir = sprintf('trim=%02d,length=%g', trimFrames, setLength_s);
outFeatDir = fullfile(outDir, trimDir, 'feat');
pcaFile    = fullfile(outDir, trimDir, sprintf('pcaData_%ddims_%dfiles.mat', pcaDims));
outPcaDir  = fullfile(outDir, trimDir, sprintf('pca_%ddims_%dfiles', pcaDims));

if iscell(filesOrPattern)
    wavFiles = filesOrPattern;
else
    wavFiles = findFiles(inDir, filesOrPattern); 
end

disp('Extracting bubble features for every file')
effn =  @(ip,op,fn) ef_bubbleFeatures(ip,op,fn, trimFrames, setLength_s, oldProfile, overwrite);
status = extractFeatures(inDir, outFeatDir, 'mat', wavFiles, ...
    effn, nJobs, part, ignoreErrors, overwrite);

matFiles = strrep(wavFiles, '.wav', '.mat');

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
    pcs = pcs(:,1:pcaDims(1));
    ensureDirExists(pcaFile);
    save(pcaFile, 'pcs', 'mu', 'sig', 'pcaDims', 'origShape', 'weightVec');
else
    load(pcaFile)
end

disp('Augmenting computed features with PCA features')
effn =  @(ip,op,fn) ef_pcaFeatures(ip,op,fn, pcs, mu, sig, pcaFile);
status = extractFeatures(outFeatDir, outPcaDir, 'mat', matFiles, ...
    effn, nJobs, part, ignoreErrors, overwrite);



function ef_bubbleFeatures(ip, op, fn, trimFrames, setLength_s, oldProfile, overwrite)

cleanWavFile = regexprep(regexprep(ip, 'bps\d+', 'bpsInf'), '\d+.wav', '000.wav');
cleanMatFile = regexprep(regexprep(op, 'bps\d+', 'bpsInf'), '\d+.mat', '000.mat');

[clean fs nfft] = loadSpecgram(cleanWavFile, setLength_s);
[mix   fs nfft] = loadSpecgram(ip, setLength_s);
[features origShape weights cleanFeat weightVec] = ...
    bubbleFeatures(clean, mix, fs, nfft, oldProfile, trimFrames);

if ~exist(cleanMatFile, 'file') || overwrite
    save(cleanMatFile, 'cleanFeat', 'origShape', 'fs', 'nfft', 'trimFrames');
end
save(op, 'features', 'weightVec', 'origShape', 'fs', 'nfft', 'trimFrames', 'oldProfile')


function ef_pcaFeatures(ip, op, fn, pcs, mu, sig, pcaFile)
load(ip)
weights = reshape(repmat(weightVec, 1, origShape(2)), size(features));
features = bsxfun(@times, bsxfun(@minus, features, mu), weights ./ sig);
pcaFeat = features * pcs;
save(op, 'pcaFeat', 'origShape', 'weightVec', 'fs', 'nfft', ...
    'trimFrames', 'oldProfile', 'pcaFile');


function [spec fs nfft] = loadSpecgram(fileName, setLength_s)
% Load a spectrogram of a wav file
win_s = 0.064;

[x fs] = wavReadBetter(fileName);
nSamp = round(fs * setLength_s);

if nSamp > 0
    if length(x) < nSamp
        toAdd = nSamp - length(x);
        x = [zeros(ceil(toAdd/2),1); x; zeros(floor(toAdd/2),1)];
    elseif length(x) > nSamp
        toCut = length(x) - nSamp;
        x = x(floor(toCut/2) : end-ceil(toCut/2)+1);
    end
    assert(length(x) == nSamp);
end

nfft = round(win_s * fs);
hop = round(nfft/4);
spec = stft(x', nfft, nfft, hop);
