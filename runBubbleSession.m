function runBubbleSession(expFile)

% Run an experiment as configured in expFile
%
% function runBubbleSession(expFile)
%
% expFile must be the name of a matlab script that creates a variable
% called "exps" holding a structure array of experiment parameters.

if ~exist('expFile', 'var') || isempty(expFile)
    error('Please provide the name of an experiment file')
end
if ~exist(expFile, 'file')
    error('expFile "%s" not found', expFile)
end
run(expFile);
assert(exist('exps', 'var') > 0, 'Make sure %s defines a variable called "exps"', expFile);

subjectName = input('\nWhat are your initials? ', 's');

dataFile = [basename(expFile) '_' subjectName '.mat'];

if exist(dataFile, 'file')
    fprintf('\nWelcome back, %s\n', subjectName);
    data = load(dataFile);
else
    fprintf('\nHi, %s, let''s get started\n', subjectName);
    data.lastStarted = cell(size(exps));
    data.lastFinished = cell(size(exps));
end

while true
    [exp choice] = getSelection(exps, data.lastStarted, data.lastFinished);
    if isempty(exp)
        break
    end

    if ~exist(exp.wavInDir, 'dir')
        error('Input directory not found: %s\nPlease fix your configuration file: %s', exp.wavInDir, expFile)
    end
    if ~exist(exp.noiseRef, 'file')
        error('Noise reference file not found: %s\nPlease fix your configuration file: %s', exp.noiseRef, expFile)
    end
    
    data.lastStarted{choice} = datetime('now','Format','yyyy-MM-dd HH:mm:ss');
    save(dataFile, '-struct', 'data');
    
    fprintf('\n\n')
    fprintf(exp.instructions)
    fprintf('\n\n')
    try
        if exp.resume
            % Try resuming old session first
            initialBps = [];
        else
            initialBps = exp.initialBps;
        end
        
        playAdaptiveListening(exp.wavInDir, exp.mixOutDir, ...
            [subjectName exp.subjectNameSuffix], exp.nRounds, initialBps, ...
            exp.dur_s, exp.snr_db, exp.noiseRef, exp.normalize, exp.allowRepeats, ...
            exp.giveFeedback, exp.vertical, exp.globalBps, exp.allowIdk)
    catch
        % If can't resume, start from scratch
        playAdaptiveListening(exp.wavInDir, exp.mixOutDir, ...
            [subjectName exp.subjectNameSuffix], exp.nRounds, exp.initialBps, ...
            exp.dur_s, exp.snr_db, exp.noiseRef, exp.normalize, exp.allowRepeats, ...
            exp.giveFeedback, exp.vertical, exp.globalBps, exp.allowIdk)
    end
    
    data.lastFinished{choice} = datetime('now','Format','yyyy-MM-dd HH:mm:ss');
    save(dataFile, '-struct', 'data');
end



function [exp choice] = getSelection(exps, lastStarted, lastFinished)

fprintf('\n\nPlease select an experiment to run:\n\n');
for i = 1:length(exps)
    if ~isempty(lastFinished{i})
        fprintf('%d: %s, (completed %s)\n', i, exps(i).name, char(lastStarted{i}));
    elseif ~isempty(lastStarted{i})
        fprintf('%d: %s, (started %s)\n', i, exps(i).name, char(lastStarted{i}));
    else
        fprintf('%d: %s\n', i, exps(i).name);
    end
end
fprintf('%d: [Quit]\n\n', length(exps)+1);

% Get input robustly
while true
    try
        choice = input('Selection: ');
        if choice == length(exps)+1
            exp = [];
        else
            exp = exps(choice);
        end
        break
    catch
    end
end
