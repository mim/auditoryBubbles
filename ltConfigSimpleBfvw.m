% Common configuration for all experiments
cfg.wavInDir = '~/Dropbox/hindiBubbles/inputData/simpleBFVW/';
cfg.mixOutDir = '~/Dropbox/hindiBubbles/results/simpleBFVW/';
cfg.noiseRef = '~/Dropbox/hindiBubbles/inputData/all_ref.wav';
% cfg.wavInDir = '../inputData/simpleBFVW/';
% cfg.mixOutDir = '../results/simpleBFVW/';
% cfg.noiseRef = '../inputData/all_ref.wav';
cfg.dur_s = 2.0;
cfg.normalize = 0;
cfg.snr_db = -25;

cfg.vertical = true;
cfg.globalBps = true;
cfg.allowIdk = false;
cfg.allowRepeats = true;

% Training, no noise
exp1 = cfg;  % Copy global configuration
exp1.name = 'Training without noise';
exp1.instructions = [ ...
    'This experiment will familiarize you with the original, noise-free sounds. \n' ...
    'Please adjust your volume so that you can hear them clearly. \n' ...
    'You will receive feedback on your answers.'];
exp1.nRounds = 10;
exp1.initialBps = inf;
exp1.giveFeedback = true;
exp1.subjectNameSuffix = 'Test';
exp1.resume = false;

% Training with noise
exp2 = cfg;  % Copy global configuration
exp2.name = 'Training with noise';
exp2.instructions = [...
    'This experiment will familiarize you with the noise and the noisy sounds. \n' ...
    'Please adjust your volume so that the noise is not too loud, but so that \n' ...
    'you can still hear the target sounds clearly. You will receive feedback on \n' ...
    'your answers'];
exp2.nRounds = 10;
exp2.initialBps = 20;
exp2.giveFeedback = true;
exp2.subjectNameSuffix = 'Test';
exp2.resume = false;

% Actual experiment, with noise
exp3 = cfg;  % Copy global configuration
exp3.name = 'Main test';
exp3.instructions = [...
    'This experiment will evaluate your ability to understand the target sounds in noise. \n' ...
    'You will not receive feedback.'];
exp3.initialBps = 20;
exp3.nRounds = 200;
exp3.giveFeedback = false;
exp3.subjectNameSuffix = '';
exp3.resume = true;

exps = [exp1 exp2 exp3];
