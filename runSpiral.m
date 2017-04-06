%% aCa words without noise
wavInDir = '/home/data/bubbles/shannon/orig/srcOneSpeakerOneUtt';
mixOutDir = '/home/data/bubbles/shannon/combinedTest';
subjectName = 'mimTest';
dur_s = 2.0;
normalize = 1;
snr_db = -25;
noiseRef = '/home/data/bubbles/shannon/speechRef.wav';
nRounds = 10;
giveFeedback = true;
initialBps = inf;
playAdaptiveListening(wavInDir, mixOutDir, subjectName, nRounds, initialBps, dur_s, snr_db, noiseRef, normalize, 1, giveFeedback, 1)


%% aCa words with noise
initialBps = 25;
playAdaptiveListening(wavInDir, mixOutDir, subjectName, nRounds, initialBps, dur_s, snr_db, noiseRef, normalize, 1, giveFeedback, 1)


%% GRID sentences without noise
wavInDir = '/home/data/bubbles/grid/id16orig';
subjectName = 'mimTest';
dur_s = 2.0;
normalize = 1;
snr_db = -25;
noiseRef = '/home/data/bubbles/grid/id16orig.wav';
nRounds = 10;
giveFeedback = true;
mixOutDir = '/home/data/bubbles/grid/id16mixTest';
initialBps = inf;
playAdaptiveListening(wavInDir, mixOutDir, subjectName, nRounds, initialBps, dur_s, snr_db, noiseRef, normalize, 1, giveFeedback, 1)


%% GRID sentences with noise
initialBps = inf;
playAdaptiveListening(wavInDir, mixOutDir, subjectName, nRounds, initialBps, dur_s, snr_db, noiseRef, normalize, 1, giveFeedback, 1)


%% timbre words without noise
wavInDir = '/home/data/bubbles/instrumentsSingle/nonWind';
mixOutDir = '/home/data/bubbles/instrumentsMix/nonWind';
subjectName = 'mimTest';
dur_s = 2.0;
normalize = 1;
snr_db = -25;
noiseRef = '/home/data/bubbles/instrumentsSingle/calibration/all.wav';
nRounds = 10;
giveFeedback = true;
initialBps = inf;
playAdaptiveListening(wavInDir, mixOutDir, subjectName, nRounds, initialBps, dur_s, snr_db, noiseRef, normalize, 1, giveFeedback, 1)


%% timbre words with noise
initialBps = 25;
playAdaptiveListening(wavInDir, mixOutDir, subjectName, nRounds, initialBps, dur_s, snr_db, noiseRef, normalize, 1, giveFeedback, 1)


%% Xagag words without noise
wavInDir = '/home/data/bubbles/vw/Xagag';
mixOutDir = '/home/data/bubbles/vw/XagagMixes';
subjectName = 'mimTest';
dur_s = 2.0;
normalize = 1;
snr_db = -25;
noiseRef = '/home/data/bubbles/vw/speechRef.wav';
nRounds = 10;
giveFeedback = true;
initialBps = inf;
playAdaptiveListening(wavInDir, mixOutDir, subjectName, nRounds, initialBps, dur_s, snr_db, noiseRef, normalize, 1, giveFeedback, 1)


%% aCa words with noise training
initialBps = 20;
playAdaptiveListening(wavInDir, mixOutDir, subjectName, nRounds, initialBps, dur_s, snr_db, noiseRef, normalize, 1, giveFeedback, 1)

