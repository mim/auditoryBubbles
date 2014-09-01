function genCosiDemo(toDisk, startAt)

% Generate demo spectrograms and wavs of importance regions

if ~exist('toDisk', 'var') || isempty(toDisk), toDisk = false; end
if ~exist('startAt', 'var') || isempty(startAt), startAt = 0; end

outDir = 'Z:\WWW\stuff\cosiDemo';
cleanWavDir = 'D:\Box Sync\bubblesShannon\oneSpeakerAllClean';
noisyWavDir = 'D:\Box Sync\bubblesShannon\listenerReps15bps';
tfifCacheDir = 'C:\Temp\data\preExp\pre2\trim=15,length=0\pca_100dims_1000files\grouped_pre2\res';
trimFrames = 15;
setLength_s = 0;
noiseShape = 0;

prt('ToFile', toDisk, 'StartAt', startAt, ...
    'Width', 3, 'Height', 3, 'NumberPlots', 0, ...
    'TargetDir', fullfile(outDir, 'img'), ...
    'SaveTicks', 1, 'Resolution', 72)

cosiDemoInner(tfifCacheDir, cleanWavDir, noisyWavDir, outDir, trimFrames, setLength_s, noiseShape);


function cosiDemoInner(resDir, cleanWavDir, noisyWavDir, outDir, trimFrames, setLength_s, noiseShape)

% Make plots from tfct data files from expWarpExtensive.

if ~exist('noiseShape', 'var') || isempty(noiseShape), noiseShape = 0; end

win_s = 0.064;
hopFrac = 0.25;
nNoisy = 3;
cleanGain = 20;
noisyGain = 2.5;

% Build signals
[resFiles,resPaths] = findFiles(resDir, 'fn=plotTfctWrapper', 0);
for s = 1:length(resPaths)
    res = load(fullfile(resPaths{s}, 'res.mat'));
    res.mat(isnan(res.mat)) = 0;
    res.clean = max(-120, res.clean);

    [baseFileName{s} wordNames{s}] = baseFileNameFor(resFiles{s});
    fprintf('%d: %s\n', s, baseFileName{s});
    cleanWavFile = cleanWavFor(cleanWavDir, baseFileName{s});
    [cleanSpec{s},clean{s},fs,nfft] = loadSpecgramNested(cleanWavFile, win_s, hopFrac, setLength_s);
    
    z = zeros(size(res.mat,1), trimFrames, size(res.mat,3));
    mat = cat(2, z, res.mat, z);

    bumpMask{s} = max(10.^(-60/20), mat(:,:,1) .* (mat(:,:,1) > 0));    
    holeMask = max(10.^(-60/20), 1 - mat(:,:,1) .* (mat(:,:,1) > 0));
    [~,~,holeNoise{s}] = genMaskedSsn(length(clean{s})/fs, fs, holeMask, win_s, hopFrac, noiseShape);
end
dither = 10^(-65/20) * (randn(size(bumpMask{s})) + 1i * randn(size(bumpMask{s})));

% Combine and write out signals
for s = 1:length(resPaths)
    % Clean speech
    cleanHtml{s} = outputWavAndPng(clean{s}, cleanGain, fs, win_s, hopFrac, outDir, baseFileName{s}, 'none', 'only');
    
    % Noise only
    noiseHtml{s} = outputWavAndPng(holeNoise{s}, noisyGain, fs, win_s, hopFrac, outDir, 'none', baseFileName{s}, 'only');
    
    for n = s%1:length(resPaths)
        importantOnly = istft(bumpMask{n} .* cleanSpec{s} + dither, nfft, nfft, round(nfft*hopFrac));
        snHtml{n,s,1} = outputWavAndPng(importantOnly, cleanGain, fs, win_s, hopFrac, outDir, baseFileName{s}, baseFileName{n}, 'unimpSil');

        snHtml{n,s,2} = outputWavAndPng(clean{s} + holeNoise{n}, noisyGain, fs, win_s, hopFrac, outDir, baseFileName{s}, baseFileName{n}, 'unimpNoise');
    end
    
    pairedSnHtml{1,s} = snHtml{s,s,1};
    pairedSnHtml{2,s} = snHtml{s,s,2};

    for n = 1:nNoisy
        wavFile = fullfile(noisyWavDir, sprintf('%s%03d.wav', baseFileName{s}, 200+n));
        [x fs] = wavReadBetter(wavFile);
        noisyHtml{n,s} = outputWavAndPng(x, noisyGain, fs, win_s, hopFrac, outDir, baseFileName{s}, sprintf('bubbles%03d', 200+n), 'noisy');
    end
end

ord1 = randperm(length(wordNames));
ord2 = randperm(length(wordNames));

% Generate HTML page
html = {};
html{end+1} = '<!DOCTYPE html>';
html{end+1} = '<html>';
html{end+1} = '<head>';
html{end+1} = '<title>Cookie cutter speech</title>';
html{end+1} = javascriptDefs();
html{end+1} = '</head>';
html{end+1} = '<body>';
html{end+1} = '<h1>Cookie cutter speech</h1>';
html{end+1} = '<p>We have identified the "important" regions of several words.  See if you can identify the words from just those regions.</p>';
html{end+1} = '<h2>Original speech</h2>';
html{end+1} = htmlTableFor([wordNames; cleanHtml], 1);
html{end+1} = '<h2>Cookie cutter speech</h2>';
html{end+1} = htmlTableFor([wordNames; pairedSnHtml(1,:)], 1);
html{end+1} = '<h2>Shuffled cookie cutter speech</h2>';
html{end+1} = htmlTableFor([pairedSnHtml(1,ord1); wordNames(ord1)], 0);
html{end+1} = '<h2>Noise tailored to each word</h2>';
html{end+1} = htmlTableFor([wordNames; noiseHtml], 1);
html{end+1} = '<h2>Speech + tailored noise</h2>';
html{end+1} = htmlTableFor([wordNames; pairedSnHtml(2,:)], 1);
html{end+1} = '<h2>Shuffled speech + tailored noise</h2>';
html{end+1} = htmlTableFor([pairedSnHtml(2,ord2); wordNames(ord2)], 0);
% html{end+1} = '<h2>Mix-and-match cookie cutter speech</h2>';
% html{end+1} = htmlTableFor([[{'Noise'} wordNames]; [listMap(@(x) sprintf('<b>%s</b>', x), wordNames)' snHtml(:,:,1)]], 1);
% html{end+1} = '<h2>Mix-and-match speech + tailored noise</h2>';
% html{end+1} = htmlTableFor([[{'Noise'} wordNames]; [listMap(@(x) sprintf('<b>%s</b>', x), wordNames)' snHtml(:,:,2)]], 1);
html{end+1} = '<h2>Bubble noise mixtures</h2>';
html{end+1} = htmlTableFor([wordNames; noisyHtml], 1);
html{end+1} = '</body>';
html{end+1} = '</html>';

html = join(html, '\n');
f = fopen(fullfile(outDir, 'index.html'), 'w');
fprintf(f, html);
fclose(f);


function html = htmlTableFor(data, hasHeader)
for i = 1:size(data,1)
    if hasHeader && (i == 1)
        data(i,:) = listMap(@(x) sprintf('<th>%s</th>', x), data(i,:));
    else
        data(i,:) = listMap(@(x) sprintf('<td>%s</td>', x), data(i,:));
    end
    eachRow{i} = join(data(i,:), '\n');
end
eachRow = listMap(@(x) sprintf('<tr>%s</tr>', x), eachRow);
html = join(eachRow, '\n');
html = sprintf('<table>%s</table>', html);


function html = outputWavAndPng(x, wavGain, origFs, win_s, hopFrac, outDir, speechName, noiseName, tag)
fs = 22050;
fileName = sprintf('%s_s=%s_n=%s', tag, speechName, noiseName);
filePath = fullfile(outDir, 'wav', [fileName '.wav']);
x = resample(x, fs, origFs);
wavWriteBetter(x * wavGain, fs, filePath);
[spec,~,fs,nfft] = loadSpecgramNested(filePath, win_s, hopFrac, -1);
plotSpectrogram(db(abs(spec / wavGain)), fileName, fs, round(nfft*hopFrac)/fs);
%html = sprintf('<a href="%s"><img src="%s"></a>', ...
%    ['wav/' fileName '.wav'], ['img/' fileName '.png']);
html = sprintf('<span id="s%d" onclick="playSound(this, ''%s'');"><img src="%s" /></span>', ...
    round(rand*1e9), ['wav/' fileName '.wav'], ['img/' fileName '.png']);

function html = javascriptDefs()
% From: http://stackoverflow.com/questions/15955183/play-mp3-with-javascript-html5
html = ['<script type="text/javascript">' ...
    '    function playSound(el,soundfile) {' ...
    '        if (el.mp3) {' ...
    '            if(el.mp3.paused) el.mp3.play();' ...
    '            else el.mp3.pause();' ...
    '        } else {' ...
    '            el.mp3 = new Audio(soundfile);' ...
    '            el.mp3.play();' ...
    '        }' ...
    '    }' ...
    '</script>'];



function [spec x fs nfft] = loadSpecgramNested(fileName, win_s, hopFrac, setLength_s)
% Load a spectrogram of a wav file

[x fs] = wavReadBetter(fileName);
nSamp = round(fs * setLength_s);

if nSamp > 0
    if length(x) < nSamp
        toAdd = nSamp - length(x);
        x = [zeros(ceil(toAdd/2),1); x; zeros(floor(toAdd/2),1)];
    elseif length(x) > nSamp
        toCut = length(x) - nSamp;
        x = x(floor(toCut/2) : end-ceil(toCut/2)+1);
    end
    assert(length(x) == nSamp);
end

nfft = round(win_s * fs / 2) * 2;
hop = round(hopFrac * nfft);
spec = stft(x', nfft, nfft, hop);


function [baseFile wordOnly] = baseFileNameFor(resFile)
% Transform 'target=acha_w3_05_07_bps15_snr-35_\fn=plotTfctWrapper' into
% 'acha_w3_05_07_bps15_snr-35_'
baseFile = strrep(fileparts(resFile), 'target=', '');
wordOnly = regexprep(baseFile, '_.*', '');
wordOnly = sprintf('&ldquo;%s&rdquo;', wordOnly);

function cleanPath = cleanWavFor(wavDir, baseFile)
% Transform 'acha_w3_05_07_bps15_snr-35_' into 'acha_w3_05_07_bpsInf_snr-35_001'
cleanWav = [regexprep(baseFile, 'bps\d+', 'bpsInf') '001.wav'];
cleanDir = regexprep(wavDir, 'bps\d+', 'bpsInf');
cleanPath = fullfile(cleanDir, cleanWav);


function plotSpectrogram(X, prtName, fs, hop_s)

cmap = easymap('bcyr', 255);
cax = [-100 5];
labels = [1 1 1];

% Labels: [ylabel xlabel colorbar]
clf  % Need this to make plots the right size for some reason...

f_khz = freqAxis_khz((size(X,1)-1)/2, fs);
ylab = 'Frequency (kHz)';
t_ms = (0:size(X,2)-1) * hop_s * 1000;

colormap(cmap)
imagesc(t_ms, f_khz, X)
caxis(cax)
axis xy
axis tight
set(gca, 'YTick', [2:2:fs/2000-1]);
if labels(1)
    set(gca, 'YTickLabel', [2:2:fs/2000-1]);
    ylabel(ylab)
else
    set(gca, 'YTickLabel', {});
end

xticks = 200:200:200*floor(max(t_ms)/200);
set(gca, 'XTick', xticks);
if labels(2)
    xlabel('Time (ms)')
    set(gca, 'XTickLabel', xticks);
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
