function jasa14auralize()

% Call auraluzeTfctSimple by itself outside of mainBubbleAnalysis()

basePcaDir = '/home/data/bubblesResults/preExp/pre2/trim=15,length=0/pca_100dims_1000files'; 
mixDir = '/home/data/bubbles/shannon/combined/bps15';
trimFrames = 15;
setLength_s = 0;
noiseShape = 0;

resultFiles = dir(fullfile(basePcaDir, 'res', 'group*'));
resultFileNames = {resultFiles.name};

for r = 1:length(resultFileNames)
    resDir = fullfile(basePcaDir, 'res', resultFileNames{r});
    tfctWavOutDir = fullfile(basePcaDir, 'wavOut', resultFileNames{r});
    auralizeTfctSimple(resDir, mixDir, tfctWavOutDir, trimFrames, setLength_s, noiseShape)
end
