# Auditory bubbles
Copyright 2013-2014 Michael Mandel <mim@mr-pc.org>, all rights reserved
Last updated 2014-06-21

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

This toolbox depends on the [mimlib toolbox](https://github.com/mim/mimlib)
for certain required supporting functions, so please download that as well.

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

```matlab
% Shared parameters
wavInDir = 'D:\input\cleanUtterances';
mixOutDir = 'D:\mixes\dev';
dur_s = 1.8;
normalize = 1;
baseSnr_db = -35;
noiseShape = 5;

% Mixes with no bubbles
% make sure baseSnr_db is set so that these are completely unintelligible
nMixes = 5;
bubblesPerSecond = 0;
mixMrtBubbleNoiseDir(wavInDir, mixOutDir, nMixes, bubblesPerSecond, baseSnr_db, dur_s, normalize, noiseShape);

% Actual bubbles files, experiment with different bubbles-per-seconds values until 
% subjects get 50% correct. When you've found that, use at least 200 mixtures per 
% utterance (nMixes)
nMixes = 5;
bubblesPerSecond = 12;
mixDir = mixMrtBubbleNoiseDir(wavInDir, mixOutDir, nMixes, bubblesPerSecond, baseSnr_db, dur_s, normalize, noiseShape);

% Clean files for reference (correct scaling, etc)
% Note that this has to be named something_bpsInf for extractBubbleFeatures to find it
nMixes = 1;
bubblesPerSecond = inf;
mixMrtBubbleNoiseDir(wavInDir, mixOutDir, nMixes, bubblesPerSecond, baseSnr_db, dur_s, normalize, noiseShape);
```

## Presentation

```matlab
subjectName = 'TLA';    % whatever you want
playListeningTestDir(mixDir, subjectName)
% file saved in mixDir, named subjectName_timestamp.csv
```

## Analysis

```matlab
% Massage and combine listening test data from multiple tests
inCsvFiles = fullfile(mixDir, 'TLA_20140621T114000.csv');  % Can be a cell array of multiple csv files
resultFile = 'D:\mixes\dev\results1.mat';
verbose = 1;
ignoreStimulusDir = 1;
processListeningData(inCsvFiles, resultFile, verbose, ignoreStimulusDir);

% Extract features from mixtures
baseFeatDir = 'D:\mixes\dev\features';
pattern = 'bps15.*.wav';
noiseShape = 5;        % whatever you use for your noise shape
pcaDims = [100 1000];  % 100 dimensions from 1000 files
usePcaDims = 40;
trimFrames = 15;
overwrite = 0;
hop_s = 0.016;         % this is the default hop size used in the analysis
mainBubbleAnalysis(mixDir, resultFile, baseFeatDir, pattern, noiseShape, pcaDims, usePcaDims, trimFrames, hop_s, overwrite)
```
