function auralizeTfctSimple(resDir, mixDir, outDir, trimFrames, setLength_s, noiseShape)

% Make plots from tfct data files from expWarpExtensive.

if ~exist('noiseShape', 'var') || isempty(noiseShape), noiseShape = 0; end

win_s = 0.064;
hopFrac = 0.25;

[resFiles,resPaths] = findFiles(resDir, 'fn=plotTfctWrapper', 0);
for target = 1:length(resPaths)
    res = load(fullfile(resPaths{target}, 'res.mat'));
    res.mat(isnan(res.mat)) = 0;
    res.clean = max(-120, res.clean);

    baseFileName = baseFileNameFor(resFiles{target});
    fprintf('%d: %s\n', target, baseFileName);
    cleanWavFile = cleanWavFor(mixDir, baseFileName);
    outFile = fullfile(outDir, [baseFileName '.wav']);
    
    [cleanSpec clean fs] = loadSpecgramNested(cleanWavFile, win_s, hopFrac, setLength_s);
    
    z = zeros(size(res.mat,1), trimFrames, size(res.mat,3));
    mat = cat(2, z, res.mat, z);
    mask = 1 - mat(:,:,1) .* (mat(:,:,1) > 0);
    [~,~,noise] = genMaskedSsn(length(clean)/fs, fs, mask, win_s, hopFrac, noiseShape);
    
    mix = clean + noise;
    wavWriteBetter(mix, fs, outFile);
end



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

nfft = round(win_s * fs);
hop = round(hopFrac * nfft);
spec = stft(x', nfft, nfft, hop);


function baseFile = baseFileNameFor(resFile)
% Transform 'target=acha_w3_05_07_bps15_snr-35_\fn=plotTfctWrapper' into
% 'acha_w3_05_07_bps15_snr-35_'
baseFile = strrep(fileparts(resFile), 'target=', '');

function cleanPath = cleanWavFor(wavDir, baseFile)
% Transform 'acha_w3_05_07_bps15_snr-35_' into 'acha_w3_05_07_bpsInf_snr-35_000'
cleanWav = [regexprep(baseFile, 'bps\d+', 'bpsInf') '000.wav'];
cleanPath = fullfile(wavDir, cleanWav);