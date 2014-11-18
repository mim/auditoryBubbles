function renameWordFiles(inDir, outDir, srcRegexp, startAt)

% Play wav files and copy to another directory with use-supplied name

if ~exist('srcRegexp', 'var') || isempty(srcRegexp), srcRegexp = '^[^_]*'; end
if ~exist('startAt', 'var') || isempty(startAt), startAt = 1; end

[files,paths] = findFiles(inDir, '.*.wav');

for i = startAt:length(files)
    choice = '';
    while isempty(choice)
        [x fs] = wavread(paths{i});
        sound(x, fs);
    
        try
            choice = input(sprintf('%d: What word did you hear? ',i), 's');
        catch err
            disp(err)
        end
    end

    outFile = fullfile(outDir, regexprep(files{i}, srcRegexp, choice));
    ensureDirExists(outFile)
    copyfile(paths{i}, outFile);
end
