%% Setup
addpath('auditoryBubbles');
addpath('mimlib');


% UPDATE THIS
subjectName = 'mim';


% This stays the same
wavInDir = '../inputData/simpleBFVW/';
mixOutDir = '../results/simpleBFVW/';
noiseRef = '../inputData/all_ref.wav';
dur_s = 2.0;
normalize = 0;
snr_db = -25;

vertical = true;
globalBps = true;
allowIdk = false;


%% Simple experiment, training, no noise
nRounds = 10;
initialBps = inf;
giveFeedback = true;

playAdaptiveListening(wavInDir, mixOutDir, [subjectName 'Test'], nRounds, initialBps, dur_s, snr_db, noiseRef, normalize, 1, giveFeedback, vertical, globalBps, allowIdk)


%% Simple experiment, training, with noise
nRounds = 10;
initialBps = 20;
giveFeedback = true;

playAdaptiveListening(wavInDir, mixOutDir, [subjectName 'Test'], nRounds, initialBps, dur_s, snr_db, noiseRef, normalize, 1, giveFeedback, vertical, globalBps, allowIdk)


%% Simple experiment, actual experiment, with noise
initialBps = 20;
nRounds = 200;
giveFeedback = false;

playAdaptiveListening(wavInDir, mixOutDir, subjectName, nRounds, initialBps, dur_s, snr_db, noiseRef, normalize, 1, giveFeedback, vertical, globalBps, allowIdk)


% NOTE: if a subject's run gets interrupted, run this to resume:
%
% initialBps = [];
% playAdaptiveListening(wavInDir, mixOutDir, subjectName, nRounds, initialBps, dur_s, snr_db, noiseRef, normalize, 1, giveFeedback, vertical, globalBps, allowIdk)
