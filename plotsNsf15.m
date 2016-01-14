function plotsNsf15(toDisk, startAt)

% Some of the plots for the NSF Small 2015 proposal

if ~exist('toDisk', 'var') || isempty(toDisk), toDisk = 0; end
if ~exist('startAt', 'var') || isempty(startAt), startAt = 0; end

featDir = '/data/data8/scratch/mandelm/chime2bubbles/features/050c010dgm12.wav/trim=00,length=0/pca_100dims_1000files';
outDir = fullfile(featDir, '/comboPlots/');

prt('ToFile', toDisk, 'StartAt', startAt, ...
    'Width', 3, 'Height', 3, 'NumberPlots', 0, ...
    'TargetDir', outDir, ...
    'SaveTicks', 1, 'Resolution', 200)

systems = {
    'tri9a_dnn_delta_depth5_smbr_from_i1lats_noisy_it4'
    'tri9a_dnn_delta_depth5_smbr_from_i1lats_noisy_it1'
    'tri8a_dnn_delta_depth5_smbr_noisy_it1'
    'tri3b'
    };
names = {
    'triphone DNN sMBR it4'
    'triphone DNN sMBR'
    'triphone DNN'
    'triphone GMM fMLLR'
    };

fs = 16000;
hop_s = 0.01;
cmap = easymap('bwr', 255);
cax = [-0.99 0.99];
maxFreq_hz = 8000;

for s=1:length(systems)
    [~,ress] = findFiles(fullfile(featDir, 'res'), ['model=' systems{s} '.*_lmwt=10_.*/fn=plotTfctWrapper/res.mat']);
    for i = 1:length(ress)
        res(i) = load(ress{i});
        
        res2 = load(strrep(strrep(ress{i}, '/res/', '/cache/'), 'fn=plotTfctWrapper/res', 'tfctAndPca'));
        fracRight(s,i) = res2.n1 / (res2.n1 + res2.n0);
        word{s,i} = regexprep(res2.groupedFile, '.*lmwt=\d+_\d\d_(.*)\.mat', '$1');
    end
    mats = cat(3,res.mat);
    prtSpectrogram(max(mats,[],3), ['max_model=' systems{s} '_lmwt=10'], fs, hop_s, cmap, cax, [1 1 1], maxFreq_hz);
    prtSpectrogram(nanmean(mats,3), ['mean_model=' systems{s} '_lmwt=10'], fs, hop_s, cmap, cax, [1 1 1], maxFreq_hz);    
end

plot(fracRight', '.-')
legend(names, 'location', 'NorthEastOutside')
set(gca, 'XTick', 1:size(word,2))
set(gca, 'XTickLabel', word(1,:))
XYrotalabel(45, 0);
prt('wer');
