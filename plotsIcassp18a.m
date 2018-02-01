function plotsIcassp18a(toDisk, startAt)

if ~exist('toDisk', 'var') || isempty(toDisk), toDisk = 0; end
if ~exist('startAt', 'var') || isempty(startAt), startAt = 0; end

inDir = '/home/data/bubbles/bcn/';
outDir = '~/work/papers/icassp18a/figures/matlab/';

fs = 44100;
hop_s = 0.016;
cmap = jet(254);
cax = [-95 5];
maxFreq_hz = 8000;
xrange_s = [0.5 1.5];

prt('ToFile', toDisk, 'StartAt', startAt, ...
    'Width', 2, 'Height', 2, 'NumberPlots', 0, ...
    'TargetDir', outDir, ...
    'SaveTicks', 1, 'Resolution', 200)

maskFiles = findFiles(inDir, '.*._mask.mat');

for f = 1:length(maskFiles)
    cleanFile = strrep(maskFiles{f}, '_mask', '_clean');
    mask = getData(load(fullfile(inDir, maskFiles{f})));
    clean = getData(load(fullfile(inDir, cleanFile)));
    fileName = strrep(maskFiles{f}, '_mask.mat', '');
    
    labels = [reMatch(fileName, 'W5DE') 1 reMatch(fileName, 'W5TA')];
    
    prtSpectrogram(cat(3, clean-30, 1-mask), fileName, fs, hop_s, cmap, cax, labels, maxFreq_hz, xrange_s)
end



function v = getData(s)

fn = fieldnames(s);
assert(length(fn) == 1)
v = s.(fn{1});
