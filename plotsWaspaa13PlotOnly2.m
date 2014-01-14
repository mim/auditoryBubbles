function plotsWaspaa13PlotOnly2(toDisk, startAt)

% Make plots for WASPAA 2013 submission on mat files generated by
% plotsWaspaa13.
    
if ~exist('toDisk', 'var') || isempty(toDisk), toDisk = false; end
if ~exist('startAt', 'var') || isempty(startAt), startAt = 0; end

prt('ToFile', toDisk, 'StartAt', startAt, ...
    'Width', 2, 'Height', 1.5, ...
    'TargetDir', 'z:\data\plots\waspaa13_2', ...
    'SaveTicks', 1, 'Resolution', 400)

matDir = 'z:\data\mrt\waspaa13PlotMats';
files = {
    {'MTurk_Version_1_din', 'MTurk_Version_1_fin', 'MTurk_Version_1_pin', 'MTurk_Version_1_sin', 'MTurk_Version_1_tin', 'MTurk_Version_1_win';
    'MTurk_Version_1_din_svm', 'MTurk_Version_1_fin_svm', 'MTurk_Version_1_pin_svm', 'MTurk_Version_1_sin_svm', 'MTurk_Version_1_tin_svm', 'MTurk_Version_1_win_svm';
    'MTurk_Version_1_din_spec', 'MTurk_Version_1_fin_spec', 'MTurk_Version_1_pin_spec', 'MTurk_Version_1_sin_spec', 'MTurk_Version_1_tin_spec', 'MTurk_Version_1_win_spec'}
    %
    {'Expert_had', 'Expert_heed', 'Expert_whod';
    'MTurk_had', 'MTurk_heed', 'MTurk_whod';
    'MTurk_had_spec', 'MTurk_heed_spec', 'MTurk_whod_spec'}
    %
    {'MTurk_Version_1_tin', 'MTurk_Version_2_tin', 'MTurk_Version_3_tin';
    'MTurk_Version_1_tin_svm', 'MTurk_Version_2_tin_svm', 'MTurk_Version_3_tin_svm';
    'MTurk_Version_1_tin_spec', 'MTurk_Version_2_tin_spec', 'MTurk_Version_3_tin_spec'}
    };

for f = 1:length(files)
    figFiles = files{f};
    for r = 1:size(figFiles,1)
        for c = 1:size(figFiles,2)
            m = load(fullfile(matDir, [figFiles{r,c} '.mat']));
            labels = [1 1 1]; %[c == 1, r == size(figFiles,1), c == size(figFiles,2)];
            plotSpecgram(m.X, m.fs, m.nFft, m.hop, m.name, m.cax, m.cmap, labels);
        end
    end
end


% Plot an example speech and noise
fileC  = 'D:\mixes\helenWords\bps12\snr-35\helenWordsPad02\din.wav';
%fileM1 = 'D:\mixes\helenWords\bps12\snr-35\helenWordsPad02\din01.wav';
fileM1 = 'D:\mixes\helenWords\bps12\snr-35\helenWordsPad02\din07.wav';
fileM2 = 'D:\mixes\helenWords\bps12\snr-35\helenWordsPad02\din03.wav';

[xc fs]  = wavReadBetter(fileC);
[xm1 fs] = wavReadBetter(fileM1);
[xm2 fs] = wavReadBetter(fileM2);

Xc  = stft(xc', m.nFft, m.nFft, m.hop);
Xm1 = stft(xm1', m.nFft, m.nFft, m.hop);
Xm2 = stft(xm2', m.nFft, m.nFft, m.hop);

Xc  = Xc(:,30:end-29);
Xm1 = Xm1(:,30:end-29);
Xn1 = Xm1 - Xc;
Xm2 = Xm2(:,30:end-29);
Xn2 = Xm2 - Xc;

plotSpecgram(db(Xc),  fs, m.nFft, m.hop, 'din_clean',  m.cax, m.cmap, [1 1 1]);
plotSpecgram(db(Xn1), fs, m.nFft, m.hop, 'din_noise1', m.cax, m.cmap, [1 1 1]);
plotSpecgram(db(Xm1), fs, m.nFft, m.hop, 'din_mix1',   m.cax, m.cmap, [1 1 1]);
plotSpecgram(db(Xn2), fs, m.nFft, m.hop, 'din_noise2', m.cax, m.cmap, [1 1 1]);
plotSpecgram(db(Xm2), fs, m.nFft, m.hop, 'din_mix2',   m.cax, m.cmap, [1 1 1]);


% % Plot PCA dimensions
% m = load('d:\mim_helenWordsPad02_din.mat');
% for d=1:10
% end



function plotSpecgram(X, fs, nFft, hop, name, cax, cmap, labels)

% Labels: [ylabel xlabel colorbar]

prtName = replaceStrs(name, {' ', '_', '''', '', '"', ''});
% saveFile = fullfile('/home/mim/work/papers/waspaa13/picMats', [prtName '.mat']);
% ensureDirExists(saveFile);
% save(saveFile, '-v7')

if size(X,1) == nFft/2+1
    f_khz = freqAxis_khz(nFft, fs);
    ylab = 'Frequency (kHz)';
else
    f_khz = 1:size(X,1);
    ylab = 'Coefficient';
end
t_ms = (0:size(X,2)-1) * hop / fs * 1000;

colormap(cmap)
imagesc(t_ms, f_khz, X)
caxis(cax)
axis xy
axis tight
%title(replaceStrs(name, {'_spec', '', '_svm', ''}), 'interpreter', 'none')
set(gca, 'YTick', [2 4 6]);
if labels(1)
    set(gca, 'YTickLabel', [2 4 6]);
    ylabel(ylab)
else
    set(gca, 'YTickLabel', {});
end

set(gca, 'XTick', [200 400 600 800]);
if labels(2)
    xlabel('Time (ms)')
    set(gca, 'XTickLabel', [200 400 600 800]);
else
    set(gca, 'XTickLabel', {});
end

if labels(3)
    hcb = colorbar;
    ticks = get(hcb, 'YTick');
    if ticks(1) == -1  % Only for masks, which are -1:1
        set(hcb, 'YTick', [-0.8 -0.4 0 0.4 0.8]);
    end
end

prt(prtName)


function f = freqAxis_khz(nFft, fs)
f = (0:nFft/2) / nFft * fs / 1000;


function s = replaceStrs(s, replacements)
% Repeatedly run strrep with pairs of values from cell array
% replacements
for i = 1:2:length(replacements)
    s = strrep(s, replacements{i}, replacements{i+1});
end
