function [pred mixFiles] = anRunStoiOnMixes(cleanFile, mixDir, mixRe)

% Run STOI on bubble noise mixtures to predict intelligibility

if ~exist('mixRe', 'var') || isempty(mixRe), mixRe = '.*.wav'; end

[~,mixFiles] = findFiles(mixDir, mixRe);

[clean cfs] = wavReadBetter(cleanFile);
for i = 1:length(mixFiles)
    [mix mfs] = wavReadBetter(mixFiles{i});
    assert(cfs == mfs);
    
    pred(i) = stoi(clean, mix, mfs);
end
