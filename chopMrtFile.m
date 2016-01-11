function chopMrtFile(wavFile, labelFile, outDir)

% Chop the inidividual words out of an annotated wavFile
%
% chopMrtFile(wavFile, labelFile, outDir)

padding_s = 0.2;
info = audioinfo(inFile);
fs = info.SampleRate;
nSamp = info.TotalSamples;
nChan = info.NumChannels;
[start_fr stop_fr word] = textread(labelFile, '%d %d %s');

lastSamp = lastSpeechSample(wavFile, nSamp, fs);
sampsPerFrame = lastSamp / stop_fr(end);
fs / sampsPerFrame

word  = lower(word);
start = max(1,     round(start_fr * sampsPerFrame - padding_s * fs));
stop  = min(nSamp, round(stop_fr  * sampsPerFrame + padding_s * fs));
%stop  = min(nSamp, stop);

for i = 1:length(word)
    if mod(i,6) == 1
        fprintf('% 7s% 7s% 7s% 7s% 7s% 7s\n', word{i:i+5});
    end
    x = audioread(wavFile, [start(i) stop(i)]);
    outFile = fullfile(outDir, [word{i} '.wav']);
    wavWriteBetter(x, fs, outFile);
end


function lastSamp = lastSpeechSample(wavFile, nSamp, fs)
% Find end of last word

threshold_dB = -60;

endStart = nSamp - 5*fs;
x = audioread(wavFile, [endStart nSamp]);
amp = max(-90, 20*log10(abs(x)));
[b a] = butter(4, 50/fs);
smoothedAmp = filtfilt(b, a, amp);
plot(smoothedAmp), drawnow
lastSamp = endStart + find(smoothedAmp > threshold_dB, 1, 'last') - 1;
