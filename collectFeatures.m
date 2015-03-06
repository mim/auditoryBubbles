function collectFeatures(word, path, groupedFile, outFile, trimFrames, oldProfile, overwrite)

% Collect features for various SVM/PCA experiments
%
% collectFeatures(word, path, groupedFile, outFile, trimFrames, oldProfile, overwrite)
%
% word is a string specifying which word to use.  path is the directory
% where the clean speech and mixes live.  Clean speech should be in
% [path]/[word].wav, mixes should be in [path]/[word][num].wav .
% groupedFile is the path to a .mat file containing the output from
% MTurk experiments grouped by digestMTurk().

if ~exist('oldProfile', 'var') || isempty(oldProfile), oldProfile = true; end
if ~exist('overwrite', 'var') || isempty(overwrite), overwrite = false; end    
if ~exist('trimFrames', 'var') || isempty(trimFrames), trimFrames = 29; end

if exist(outFile, 'file') && ~overwrite
    fprintf('Skipping %s\n', outFile)
    return
end

% Should contain a variable "grouped"
load(groupedFile);
ansFile = strrep(grouped(:,3), '\', filesep);

mixPaths = {}; fracRight = []; isRight = [];
for i = 1:length(ansFile)
    if ~reMatch(ansFile{i}, [word '\d+\.wav']), continue, end
    mixPath = fullfile(path, ansFile{i});
    if exist(mixPath, 'file')
        mixPaths{end+1} = mixPath;
        fracRight(end+1) = grouped{i,5};
    end
end
mixPaths = mixPaths(:); fracRight = fracRight(:);

cleanFile = fullfile(path, [word '.wav']);
if ~exist(cleanFile, 'file')
    cleanFile = fullfile(path, [regexprep(word, 'bps[^_/\\]*', 'bpsInf') '000.wav']);
end
[clean fs nFft] = loadSpecgram(cleanFile);

%features = zeros(length(mixPaths), 2*numel(clean));
for i = 1:length(mixPaths)
    mix = loadSpecgram(mixPaths{i});
    [features(i,:) origShape weights cleanFeat] = ...
        bubbleFeatures(clean, mix, fs, nFft, oldProfile, trimFrames);
end

fprintf('%d files, avg label: %g\n', size(features,1), mean(fracRight > 0.5))

[pcs pcaFeat] = pca(bsxfun(@times, weights, zscore(features)));
%[pcaFeat pcs] = pca(bsxfun(@times, weights, zscore(features))');

ensureDirExists(outFile)
save(outFile, 'features', 'mixPaths', 'fracRight', ...
     'pcs', 'pcaFeat', 'fs', 'nFft', 'cleanFeat', 'weights', ...
     'origShape')
% save(outFile, '-mat-binary', 'features', 'mixPaths', 'fracRight', ...
%      'pcs', 'pcaFeat', 'fs', 'nFft', 'cleanFeat', 'weights', ...
%      'origShape')


function [spec fs nfft] = loadSpecgram(fileName)
% Load a spectrogram of a wav file
win_s = 0.064;

[x fs] = wavReadBetter(fileName);
nfft = round(win_s * fs);
hop = round(nfft/4);
spec = stft(x', nfft, nfft, hop);

