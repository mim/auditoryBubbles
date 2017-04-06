function mixBubbleNoiseAmi(inFile, outDir, shortName, nRep, bps, snr_dB, transcript)

% Repeat a single AMI utterance many times, mixing the whole thing with
% bubble noise.  Kaldi AMI recognizer can treat this as a single long
% recording, like it does with the normal AMI recordings.
% 
% Put the combined noisy wav file in /scratch/mim/kaldi/ami/bubbles/
% Put the bubbles_..._orig directory in egs/ami/s5b/data/ihm/

sep_s = 0.3;
scale_dB = 0;
scale = 10^(scale_dB/20);
snr = 10^(snr_dB/20);

[x fs] = audioread(inFile);
padHundredths = ceil(size(x,1) * 100/fs)* fs/100 - size(x,1); % Pad to the next 0.01 second
pad = padHundredths + round(sep_s * fs);
x = [x; zeros(pad,size(x,2))];
len = size(x,1);
len_s = size(x,1) / fs;
% len_s includes sep_s

clean = scale * snr * repmat(x, nRep, 1);
noise = scale * genBubbleNoise(len_s * nRep, fs, bps, 1, [], [], [], [], 1, inFile);

wavWriteBetter(noise + clean, fs, fullfile(outDir, nameFor(shortName, bps, snr_dB)));
wavWriteBetter(clean, fs, fullfile(outDir, nameFor(shortName, inf, snr_dB)));

outDirMixes = fullfile(outDir, 'mixes', sprintf('bps%d', bps));
wavWriteBetter(clean(1:len,:), fs, fullfile(outDir, 'mixes', 'bpsInf', nameFor(shortName, inf, snr_dB, 1, 0)));
for r = 1:nRep
    outFile = fullfile(outDirMixes, nameFor(shortName, bps, snr_dB, 1, r));
    inds = (r-1)*len+1 : r*len;
    wavWriteBetter(clean(inds,:) + noise(inds,:), fs, outFile)
end

writeAmiMetadata(outDir, shortName, nRep, bps, snr_dB, transcript, len_s, sep_s);



function fileName = nameFor(shortName, bps, snr, ext, rep)

fileName = sprintf('%s_bps%d_snr%d', shortName, bps, snr);

if nargin >= 5
    fileName = sprintf('%s_%03d', fileName, rep);
end
if nargin < 4 || ext
    fileName = [fileName '.wav'];
end


%%%%%%%%%%%%%%%
function writeAmiMetadata(outDir, shortName, nRep, bps, snr_dB, transcript, len_s, sep_s)

wavDir = '/scratch/mim/kaldi/ami/bubbles/';
speechLen_s = len_s - sep_s;

side = nameFor(shortName, bps, snr_dB, 0);
wav = nameFor(shortName, bps, snr_dB, 0);
speaker = nameFor(shortName, bps, snr_dB, 0);
[utts start_s end_s] = uttNames(shortName, bps, snr_dB, speechLen_s, sep_s, nRep);
outMdDir = fullfile(outDir, [nameFor(['bubbles_' shortName], bps, snr_dB, 0) '_orig']);

write_reco2file_and_channel(outMdDir, side, wav);
write_segments(outMdDir, utts, speaker, start_s, end_s);
write_spk2utt(outMdDir, speaker, utts);
write_stm(outMdDir, wav, speaker, start_s, end_s, transcript);
write_text(outMdDir, utts, transcript);
write_utt2dur(outMdDir, utts, speechLen_s);
write_utt2spk(outMdDir, utts, speaker);
write_wav_scp(outMdDir, side, wavDir, wav);



function write_reco2file_and_channel(outDir, side, wav)
% reco2file_and_channel -- which "side" of the conversation to use
% notice_bps20_snr-10 notice_bps20_snr-10 A
lines = {sprintf('%s %s A', side, wav)};
writeTextFile(outDir, 'reco2file_and_channel', lines);

function write_segments(outDir, utts, speaker, start_s, end_s)
% segments -- start and end point of each utterance in longer recordings
% notice_bps20_snr-10_0000000_0000345 notice_bps20_snr-10 0.00 3.45
% notice_bps20_snr-10_0000346_0000690 notice_bps20_snr-10 3.46 6.90
% ...
for i = 1:length(utts)
    lines{i} = sprintf('%s %s %0.2f %0.2f', utts{i}, speaker, start_s(i), end_s(i));
end
writeTextFile(outDir, 'segments', lines)

function write_spk2utt(outDir, speaker, utts)
% spk2utt -- speaker for each utterance
% notice_bps20_snr-10 notice_bps20_snr-10_0000000_0000345 notice_bps20_snr-10_0000346_0000690 ...
lines = {[speaker ' ' strjoin(utts, ' ')]};
writeTextFile(outDir, 'spk2utt', lines);

function write_stm(outDir, wav, speaker, start_s, end_s, transcript)
% stm -- true transcript, plus some extra info
% notice_bps20_snr-10 A notice_bps20_snr-10 0.00 3.45 AND YOU PICK UP ON THINGS THAT YOU DID NOT REALLY NOTICE THE FIRST TIME AROUND
% notice_bps20_snr-10 A notice_bps20_snr-10 3.46 6.90 AND YOU PICK UP ON THINGS THAT YOU DID NOT REALLY NOTICE THE FIRST TIME AROUND
% ...
for i = 1:length(start_s)
    lines{i} = sprintf('%s A %s %0.2f %0.2f %s', wav, speaker, start_s(i), end_s(i), transcript);
end
writeTextFile(outDir, 'stm', lines);

function write_text(outDir, utts, transcript)
% text -- true transcript
% notice_bps20_snr-10_0000000_0000345 AND YOU PICK UP ON THINGS THAT YOU DID NOT REALLY NOTICE THE FIRST TIME AROUND
% notice_bps20_snr-10_0000346_0000690 AND YOU PICK UP ON THINGS THAT YOU DID NOT REALLY NOTICE THE FIRST TIME AROUND
% ...
for i = 1:length(utts)
    lines{i} = [utts{i} ' ' transcript];
end
writeTextFile(outDir, 'text', lines);

function write_utt2dur(outDir, utts, len_s)
% utt2dur -- duration of each utterance in seconds
% notice_bps20_snr-10_0000000_0000345 3.45
% notice_bps20_snr-10_0000346_0000690 3.45
% ...
for i = 1:length(utts)
    lines{i} = sprintf('%s %0.2f', utts{i}, len_s);
end
writeTextFile(outDir, 'utt2dur', lines);

function write_utt2spk(outDir, utts, speaker)
% utt2spk -- speaker for each utterance
% notice_bps20_snr-10_0000000_0000345 notice_bps20_snr-10
% notice_bps20_snr-10_0000346_0000690 notice_bps20_snr-10
% ...
for i = 1:length(utts)
    lines{i} = [utts{i} ' ' speaker];
end
writeTextFile(outDir, 'utt2spk', lines);

function write_wav_scp(outDir, side, wavDir, wav)
% wav.scp -- sox commands for generating files from files on hard disk
% notice_bps20_snr-10 sox -c 1 -t wavpcm -s /scratch/mim/kaldi/ami/bubbles/notice_bps20_snr-10.wav -t wavpcm - |
wavPath = fullfile(wavDir, [wav '.wav']);
lines = {sprintf('%s sox -c 1 -t wavpcm -s %s -t wavpcm - |', side, wavPath)};
writeTextFile(outDir, 'wav.scp', lines);



function writeTextFile(outDir, fileOnly, lines)
% Write a cell array of lines of text to a text file
outFile = fullfile(outDir, fileOnly);
ensureDirExists(outFile);
f = fopen(outFile, 'w');
for i = 1:length(lines)
    fprintf(f, [lines{i} '\n']);
end
fclose(f);    
    

function [names start_s end_s] = uttNames(shortName, bps, snr, len_s, sep_s, nRep)
uttBase = nameFor(shortName, bps, snr, 0);
for r = 1:nRep
    start_s(r) = (len_s + sep_s) * (r-1);
    end_s(r) = start_s(r) + len_s;
    names{r} = sprintf('%s_%07d_%07d', uttBase, round(start_s(r)*100), round(end_s(r)*100));
end

       
function [fileName side speaker] = parseUttName(uttName)
% E.g., uttName = AMI_ES2011a_H00_FEE041_0003427_0003714
% filename: ES2011a.Headset-0
% side: AMI_ES2011a_H00
% speaker: AMI_ES2011a_H00_FEE041

fileName = regexprep(uttName, 'AMI_(.*)_H0(\d).*', '$1.Headset-$2');
vals = split(uttName, '_');
side = strjoin(vals(1:3), '_');
speaker = strjoin(vals(1:4), '_');
