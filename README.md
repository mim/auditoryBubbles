# Bubble noise generation, presentation, and analysis
Michael Mandel

## Overview

This toolbox is used for creating, running, and analyzing "bubble" noise 
listening tests.  The goal of this procedure is to identify the importance 
of each time-frequency point in the spectrogram of an utterance to its 
intelligibility in noise.  To do this, the toolbox creates many mixtures of
the same utterances with different instances of "bubble" noise.  The 
analysis then identifies TF points where the noise is correlated with the 
intelligibility of the mixture (called time frequency importance functions 
(TFIFs) or time-frequency cross tabulation images (TFCTs)).  The toolbox 
will also run a predictive analysis on the mixtures, using cross-validation 
to train a classifier to predict whether mixtures of each original clean 
utterance were intelligible to listeners and then measure its prediction 
accuracy on held out test data.


### Please cite

Please cite one of the following paper if you use this toolbox:

Michael I Mandel, Sarah E Yoho, and Eric W Healy. Generalizing 
  time-frequency importance functions across noises, talkers, and phonemes. 
  In Proceedings of Interspeech, 2014. To appear.

Michael I. Mandel. Learning an intelligibility map of individual 
  utterances. In IEEE Workshop on Applications of Signal Processing to 
  Audio and Acoustics (WASPAA), 2013.


## Stimulus Generation

### Set speech profile for speech shaped noise

Edit speechProfile.m to add your own noiseShape value using your own file 
as the source material and appropriate quantile and smoothing parameters.  
We assume here that you use noiseShape = 5.


### Generate mixtures

% Shared parameters
wavInDir = 'D:\Box Sync\data\mrt\shannon\srcOneSpeakerOneUtt';
dur_s = 1.8;
normalize = 1;
noiseShape = 5;
baseSnr_db = -35;

% Mixes with no bubbles
% make sure baseSnr_db is set so that these are completely unintelligible
nMixes = 5;
bubblesPerSecond = 0;
noiseDir = 'D:\mixes\shannon\oneSpeaker0bps';
mixMrtBubbleNoiseDir(wavInDir, noiseDir, nMixes, bubblesPerSecond, baseSnr_db, dur_s, normalize, noiseShape);

% Actual bubbles files
mixDir = 'D:\mixes\shannon\oneSpeaker15bps';
nMixes = 200;
bubblesPerSecond = 15;
mixMrtBubbleNoiseDir(wavInDir, mixDir, nMixes, bubblesPerSecond, baseSnr_db, dur_s, normalize, noiseShape);

% Clean files for reference
cleanDir = 'D:\mixes\shannon\oneSpeakerClean';
nMixes = 1;
bubblesPerSecond = inf;
mixMrtBubbleNoiseDir(wavInDir, cleanDir, nMixes, bubblesPerSecond, baseSnr_db, dur_s, normalize, noiseShape);


## Presentation

subjectName = 'TLA';
playListeningTestDir(mixDir, subjectName)
% file saved in mixDir, named subjectName_timestamp.csv


## Analysis

% Massage and combine listening test data from multiple tests
inCsvFiles = fullfile(mixDir, 'TLA_20140620T112233.csv');  % Can be a cell array of multiple csv files
resultFile = 'D:\Box Sync\data\mrt\shannonResults\preExps\grouped_pre1sub1';
verbose = 1;
processListeningData(inCsvFiles, resultFile, verbose);

% Extract features from mixtures
baseFeatDir = 'C:\Temp\mrtFeatures\timbre\mim';
pattern = 'bps15.*.wav';
pcaDims = [100 1000];  % 100 dimensions from 1000 files
trimFrames = 15;
setLength_s = 0;
noiseShape = 5;
overwrite = 0;
extractBubbleFeatures(mixDir, baseFeatDir, filesOrPattern, pcaDims, trimFrames, setLength_s, noiseShape, overwrite)

% Compute PCA on features
trimDir = sprintf('trim=%d_length=%d', trimFrames, setLength_s);
pcaDimStr = sprintf('%ddims_%dfiles', pcaDims);
featDir = fullfile(featDir, trimDir, ['pca_' pcaDimStr]);
pcaFeatDir = fullfile(featDir, trimDir, ['pcaFeat_' pcaDimStr]);
collectPcaFeatures(featDir, resultFile, pcaFeatDir, overwrite);

% Compute statistics necessary for plotting pictures, running SVM experiments
cacheDir = fullfile(featDir, trimDir, ['cache_' pcaDimStr]);
pcaDataFile = fullfile(featDir, trimDir, ['pcaData_' pcaDimStr]);
extractTfctAndPcaSimple(cacheDir, featDir, pcaDataFile, resultFile, overwrite)

% Plot pictures, run SVM cross validation within each file
plotDir = fullfile(featDir, trimDir, ['plots_', pcaDimStr]);
pcaDims = 40;
expWarpSimpleFromCache(plotDir, cacheDir, pcaDims);
