function mixBubbleNoiseAmi(inFile, outDir, shortName, nRep, bps, snr_dB)

% Repeat a single AMI utterance many times, mixing the whole thing with
% bubble noise.  Kaldi AMI recognizer can treat this as a single long
% recording, like it does with the normal AMI recordings.

pauseBetween_s = 0.3;
scale_dB = 6;
scale = 10^(scale_dB/20);
snr = 10^(snr_dB/20);

[x fs] = audioread(inFile);
pauseBetween = round(pauseBetween_s * fs);
x = [x; zeros(pauseBetween,size(x,2))];
len = size(x,1);
len_s = size(x,1) / fs;

clean = scale * snr * repmat(x, nRep, 1);
noise = scale * genBubbleNoise(len_s * nRep, fs, bps, 1, [], [], [], [], 1, inFile);

wavWriteBetter(noise + clean, fs, fullfile(outDir, nameFor(shortName, bps, snr_dB)));
wavWriteBetter(clean, fs, fullfile(outDir, nameFor(shortName, inf, snr_dB)));

outDirMixes = fullfile(outDir, 'mixes', sprintf('bps%d', bps));
wavWriteBetter(clean(1:len,:), fs, fullfile(outDir, 'mixes', 'bpsInf', nameFor(shortName, inf, snr_dB, 0)));
for r = 1:nRep
    outFile = fullfile(outDirMixes, nameFor(shortName, bps, snr_dB, r));
    inds = (r-1)*len+1 : r*len;
    wavWriteBetter(clean(inds,:) + noise(inds,:), fs, outFile)
end


function fileName = nameFor(shortName, bps, snr, rep)

fileName = sprintf('%s_bps%d_snr%d', shortName, bps, snr);

if nargin < 4
    fileName = [fileName '.wav'];
else
    fileName = sprintf('%s_%03d.wav', fileName, rep);
end
