function plotsNsf15b(toDisk, startAt)

% Some of the plots for the NSF Small 2015 proposal

if ~exist('toDisk', 'var') || isempty(toDisk), toDisk = 0; end
if ~exist('startAt', 'var') || isempty(startAt), startAt = 0; end

asrFeatDir = 'C:\Temp\data\asrBubblesRes';
humanResFile = 'C:\Temp\data\chime2_050c010d\trim=10,length=0\pca_100dims_1000files\res\mim500\target=L_bps10_snr-25_\fn=plotPbc\res.mat';
preResDir = 'C:\Temp\data\preExp\pre2\trim=15,length=0\pca_100dims_1000files\res\grouped_pre2sub3';
outDir = 'Z:\data\plots\nsf15';

prt('ToFile', toDisk, 'StartAt', startAt, ...
    'Width', 3, 'Height', 3, 'NumberPlots', 0, ...
    'TargetDir', outDir, ...
    'SaveTicks', 1, 'Resolution', 200)

systems = {
    'tri9a_dnn_delta_depth5_smbr_from_i1lats_noisy_it4'
    'tri3b'
    };
names = {
    'DNN_sMBR'
    'GMM_fMLLR'
    };

fs = 16000;
hop_s = 0.016;
%tfifCmap = easymap('bwr', 255);
tfifCmap = easymap('bcyr', 255);
tfifCax = [0 .6];
specCmap = easymap('bcyr', 255);
specCax = [-100 5];
maxFreq_hz = 8000;
asrXrange_s = [0.560 1.358];
humanXrange_s = [0.032 0.848];
preTfifCax = [0 .4];
preMaxFreq_hz = 6000;

for s=1:length(systems)
    [~,paths] = findFiles(asrFeatDir, ['model=' systems{s} '.*\\fn=plotPbc\\res.mat']);
    for i = 1:length(paths)
        lmwtStr = regexprep(paths{i}, '.*(lmwt=\d+).*', '$1');
        res = load(paths{i});
        sig = exp((res.pval - 1)/0.05);
        prtSpectrogram(res.pbc .* sig, [names{s} '_' lmwtStr '_corr'], fs, hop_s, tfifCmap, tfifCax, [0 0 s==2], maxFreq_hz, asrXrange_s);
        prtSpectrogram(res.clean, [names{s} '_' lmwtStr '_clean'], fs, hop_s, specCmap, specCax, [0 1 s==2], maxFreq_hz, asrXrange_s);
    end
end

% Plot human results
res = load(humanResFile);
sig = exp((res.pval - 1)/0.05);
prtSpectrogram(res.pbc .* sig, 'human_corr', fs, hop_s, tfifCmap, tfifCax, [1 0 0], maxFreq_hz, humanXrange_s);
prtSpectrogram(res.clean, 'human_clean', fs, hop_s, specCmap, specCax, [1 1 0], maxFreq_hz, humanXrange_s);

% Plot pre-exp human results
[files,paths] = findFiles(preResDir, 'fn=plotPbc\\res.mat');
for i = 1:length(paths)
    name = regexprep(files{i}, 'target=([^_]*)_.*', '$1');
    res = load(paths{i});
    sig = exp((res.pval - 1)/0.05);
    prtSpectrogram(res.pbc .* sig, [name '_corr'], fs, hop_s, tfifCmap, preTfifCax, [i==1 0 i==6], preMaxFreq_hz);
    prtSpectrogram(res.clean, [name '_clean'], fs, hop_s, specCmap, specCax, [i==1 1 i==6], preMaxFreq_hz);
end
