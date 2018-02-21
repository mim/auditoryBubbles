function [featDir] = mainBubbleAnalysis(mixDir, resultFile, baseFeatDir, pattern, noiseShape, pcaDims, usePcaDims, trimFrames, win_s, overwrite, setLength_s, maxPlotHz, condition, useFdr)

% Run several analysis steps together
%
% mainBubbleAnalysis(baseFeatDir, pattern, noiseShape, pcaDims, usePcaDims, trimFrames, win_s, overwrite)
%
% Extracts features from bubble mixtures, collects reduced dimension feature
% vectors for all mixtures involving the same clean speech file, computes
% statistics necessary for plotting pictures and running SVM experiments,
% runs SVM cross validation within each file, massages TFCT data, and plots
% pictures.
%
% Inputs:
%   mixDir       base directory of tree containing mixtures
%   resultFile   mat file containing digested listening test results (or cell array of several for the same features)
%   baseFeatDir  base directory of tree in which to write analysis
%   patterns     regular expression for finding mixture files to analyze
%   noiseShape   numerical specifier of noise type used to generate
%                mixtures, passed to speechProfile 
%   pcaDims      [dims files] pair, specifying maximum number of PCA
%                dimensions and number of files to use to compute transformation
%   usePcaDims   number of PCA dimension to actually use in classification
%   trimFrames   number of frames to trim from each spectrogram before PCA
%   win_s        window size in seconds used in analysis between frames (hop size is 1/4 of this)
%   overwrite    if 0, do not overwrite existing files

if ~exist('pcaDims', 'var') || isempty(pcaDims), pcaDims = [100 1000]; end
if ~exist('usePcaDims', 'var') || isempty(usePcaDims), usePcaDims = 40; end
if ~exist('trimFrames', 'var') || isempty(trimFrames), trimFrames = 0; end
if ~exist('win_s', 'var') || isempty(win_s), win_s = 0.064; end
if ~exist('overwrite', 'var') || isempty(overwrite), overwrite = 0; end
if ~exist('setLength_s', 'var') || isempty(setLength_s), setLength_s = 0; end
if ~exist('maxPlotHz', 'var') || isempty(maxPlotHz), maxPlotHz = inf; end
if ~exist('condition', 'var') || isempty(condition), condition = 'bubbles'; end
if ~exist('useFdr', 'var') || isempty(useFdr), useFdr = false; end

excludePattern = 'bpsInf';
if ~iscell(resultFile), resultFile = {resultFile}; end

% Figure out sampling rate for plots
[mixFiles,mixPaths] = findFiles(mixDir, pattern, 1, excludePattern);
[~,fs] = audioread(mixPaths{1});

% Extract features from mixtures once
[basePcaDir featDir] = extractBubbleFeatures(mixDir, baseFeatDir, mixFiles, pcaDims, trimFrames, setLength_s, win_s, noiseShape, overwrite >= 4);

% Run analyses for several results files
for r = 1:length(resultFile)
    resultFileName = basename(resultFile{r}, 0);

    % Collect PCA features for mixes of the same clean file
    pcaFeatDir = fullfile(basePcaDir, 'feat');
    groupedFeatDir = fullfile(basePcaDir, 'grouped', resultFileName);
    collectPcaFeatures(pcaFeatDir, featDir, resultFile{r}, groupedFeatDir, overwrite >= 3, condition);

    % Compute statistics necessary for plotting pictures, running SVM experiments
    cacheDir = fullfile(basePcaDir, 'cache', resultFileName);
    pcaDataFile = fullfile(basePcaDir, 'data.mat');
    extractTfctAndPcaSimple(cacheDir, featDir, groupedFeatDir, pcaDataFile, resultFile{r}, overwrite >= 2)

    % Run SVM cross validation within each file, massage TFCT data
    resDir = fullfile(basePcaDir, 'res', resultFileName);
    expWarpSimpleFromCache(resDir, cacheDir, usePcaDims, overwrite >= 1, useFdr);

    % Plot pictures
    plotDir = fullfile(basePcaDir, 'plots', resultFileName);
    toDisk = 1;
    startAt = 0;
    plotsSimple(resDir, plotDir, fs, win_s/4, toDisk, startAt, maxPlotHz);

    %nExamples = 5;
    %plotExamples(mixDir, plotDir, fs, hop_s, toDisk, startAt, maxPlotFreq, nExamples);

    % Generate mixtures using TFCT as noise mask
    tfctWavOutDir = fullfile(basePcaDir, 'wavOut', resultFileName);
    auralizeTfctSimple(resDir, mixDir, tfctWavOutDir, trimFrames, setLength_s, noiseShape)
end
