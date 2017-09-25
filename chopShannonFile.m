function chopShannonFile(continuousFile, outDir, minDur_s, noiseFloor_db, maxPause_s)

% Chop individual words out of a single long recording of words separated
% by pauses.  Sort resulting files by duration.

if ~exist('noiseFloor_db', 'var') || isempty(noiseFloor_db), noiseFloor_db = -30; end
if ~exist('maxPause_s', 'var') || isempty(maxPause_s), maxPause_s = 0.5; end
if ~exist('minDur_s', 'var') || isempty(minDur_s), minDur_s = 0.2; end

[x fs] = audioread(continuousFile);
x_db = max(-100, db(x));
[b a] = butter(4, 5 / fs);
xlp = filtfilt(b, a, x_db);

peakVal = max(xlp);
active = xlp > peakVal + noiseFloor_db;
lastOn = zeros(size(active));
lastOn(1) = inf;
for i = 2:length(lastOn)
    if active(i)
        lastOn(i) = 0;
    else
        lastOn(i) = lastOn(i-1) + 1;
    end
end
lastOn(end) = inf;
activeSmoothed = lastOn <= minDur_s * fs;
onOff = diff(activeSmoothed);
ons   = max(1, find(onOff > 0) - minDur_s*fs);
offs  = find(onOff < 0);

starts = max(ons - maxPause_s*fs, [1; offs(1:end-1)]);
stops  = min(offs + maxPause_s*fs, [ons(2:end); length(x)]);

onOffStartStop = zeros(size(lastOn));
onOffStartStop(starts) = 1;
onOffStartStop(stops)  = 2;

plot((1:length(x))/fs, [x_db xlp activeSmoothed*100 onOffStartStop*33]);

lengths_s = (offs - ons) / fs;
[~,ord] = sort(lengths_s);
keep = ord;

for i = 1:length(keep)
    fprintf('%d: %gs, %d\n', i, lengths_s(keep(i)), keep(i));
end

for i = 1:length(keep)
    outFile = fullfile(outDir, sprintf('%s_%03d_%03d.wav', basename(continuousFile, 0), i, keep(i)));
    wavWriteBetter(x(starts(keep(i)):stops(keep(i)),:), fs, outFile);
end
