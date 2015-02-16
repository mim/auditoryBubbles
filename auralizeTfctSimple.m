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
    if ~exist(cleanWavFile, 'file')
        fprintf('^^^ Skipping, clean file not found ^^^\n');
        continue
    end
    
    nuOutFile = fullfile(outDir, [baseFileName 'noiseExceptImportant.wav']);
    niOutFile = fullfile(outDir, [baseFileName 'noiseOnlyImportant.wav']);
    suOutFile = fullfile(outDir, [baseFileName 'silenceExceptImportant.wav']);
    siOutFile = fullfile(outDir, [baseFileName 'silenceOnlyImportant.wav']);
    
    [cleanSpec,clean,fs,nfft] = loadSpecgramNested(cleanWavFile, win_s, hopFrac, setLength_s);
    
    z = zeros(size(res.mat,1), trimFrames, size(res.mat,3));
    mat = cat(2, z, res.mat, z);
    sig = -0.05 * log(mat(:,:,1) .* (mat(:,:,1) > 0));

    % Noise at the important parts of the signal
    %bumpMask = sig2mask(sig, 0.04999, 0.05, -80, 0);
    %bumpMask = sig2mask(sig, 0.01, 0.05, -80, 0);
    %bumpMask = sig2mask(sig, 0.02, 0.05, -80, 0);
    bumpMask = sig2mask(sig, 0.05, 0.10, -80, 0);
    [~,~,bumpNoise] = genMaskedSsn(length(clean)/fs, fs, bumpMask, win_s, hopFrac, noiseShape);
    wavWriteBetter(clean + bumpNoise, fs, niOutFile);
    
    % Noise at the unimportant parts of the signal
    %holeMask = max(10.^(-60/20), 1 - mat(:,:,1) .* (mat(:,:,1) > 0));  % Not really sure what this is...
    %holeMask = sig2mask(sig, .05, .05, -80, 0);
    %holeMask = sig2mask(sig, .05, .01, -80, 0);
    %holeMask = sig2mask(sig, .05, .02, -80, 0);
    holeMask = sig2mask(sig, .10, .05, -80, 0);
    [~,~,holeNoise] = genMaskedSsn(length(clean)/fs, fs, holeMask, win_s, hopFrac, noiseShape);
    wavWriteBetter(clean + holeNoise, fs, nuOutFile);
    
    % No noise, unimportant parts of signal set to silence
    importantOnly = istft(bumpMask .* cleanSpec, nfft, nfft, round(nfft*hopFrac));
    wavWriteBetter(importantOnly, fs, suOutFile);

    % No noise, important parts of signal set to silence
    importantOnly = istft(holeMask .* cleanSpec, nfft, nfft, round(nfft*hopFrac));
    wavWriteBetter(importantOnly, fs, siOutFile);
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
cleanDir = regexprep(wavDir, 'bps\d+', 'bpsInf');
cleanPath = fullfile(cleanDir, cleanWav);


function mask = sig2mask(sig, maxSig, minSig, minMask_db, maxMask_db)
scaledSig = (maxMask_db - minMask_db) * (sig - minSig) / (maxSig - minSig);
mask = 10.^(1/20 * lim(scaledSig, minMask_db, maxMask_db));
