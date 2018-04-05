%% Setup
addpath('bubbleNoise')
addpath('mimLib')


% UPDATE THIS
subjectName = 'sc';


% This stays the same
wavInDir = '../inputData/windC4E4/';
mixOutDir = '../results/windC4E4/';
noiseRef = '../inputData/windC4E4_ref.wav';
dur_s = 2.0;
normalize = 0;
snr_db = -37;


%% Wind instruments, training, no noise
nRounds = 10;
giveFeedback = true;
initialBps = inf;

playAdaptiveListening(wavInDir, mixOutDir, [subjectName 'Test'], nRounds, initialBps, dur_s, snr_db, noiseRef, normalize, 1, giveFeedback, 1)


%% Wind instruments, training, with noise
initialBps = 25;

playAdaptiveListening(wavInDir, mixOutDir, [subjectName 'Test'], nRounds, initialBps, dur_s, snr_db, noiseRef, normalize, 1, giveFeedback, 1)


%% Wind instruments, actual experiment, with noise
initialBps = 25;
nRounds = 200;
giveFeedback = false;

playAdaptiveListening(wavInDir, mixOutDir, subjectName, nRounds, initialBps, dur_s, snr_db, noiseRef, normalize, 1, giveFeedback, 1)


% NOTE: if a subject's run gets interrupted, run this to resume:
%
% initialBps = [];
% playAdaptiveListening(wavInDir, mixOutDir, subjectName, nRounds, initialBps, dur_s, snr_db, noiseRef, normalize, 1, giveFeedback, 1)
