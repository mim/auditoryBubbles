function combineWavsIntoNoiseRef(wavInDir, noiseRefFileOut, overwrite)

% Create a noise reference file by concatenating all of the wav files in
% wavInDir and saving the concatenated file to noiseRefFileOut.

if ~exist('overwrite', 'var') || isempty(overwrite), overwrite = false; end

if exist(noiseRefFileOut, 'file') && ~overwrite
    warning('File %s already exists, use argument overwrite=true to force', noiseRefFileOut)
    return
end
    
[~,files] = findFiles(wavInDir, '.*.wav');

x = [];
fs = [];
for i=1:length(files)
    [xt fst] = audioread(files{i});
    assert(isempty(fs) || (fst == fs))
    fs = fst;
    x = [x; xt]; 
end
wavWriteBetter(x, fs, noiseRefFileOut)
