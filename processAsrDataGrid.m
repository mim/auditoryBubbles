function processAsrDataGrid(baseName, model, dataset, resDir)

% Process listening test data for kaldi GRID results.
%
%   processAsrDataGrid(baseName, model, dataset, [outResultDir])
%
% Wrapper around processAsrData()
%
% Inputs:
%   baseName: base name of recognizer, e.g., 'chime2-grid-baseline'
%   model:    name of the model within that recognizer, e.g., 'tri2b' 
%   dataset:  name of dataset within that recognizer, e.g., 'devel'
%   resDir:   directory to write output in, results are qualilfied by
%             baseName, model, and dataset within this directory
%
% Each result file is an Nx6 cell array with fields: 
%   model, [blank], noisyFile, guess, isCorrect, rightAnswer

kaldiDir = sprintf('/data/data14/scratch/mandelm/kaldi/%s/', baseName);
transFile = fullfile(kaldiDir, sprintf('exp/%s/decode_%s/scoring/trans.txt', model, dataset));
noisyLines = textArray(transFile);
if isempty(noisyLines{end})
    noisyLines = noisyLines(1:end-1);  % Remove trailing empty line...
end

gtLines = deriveGtLines(noisyLines);

modelName = sprintf('%s_%s_%s', baseName, model, dataset);

noisyIdToFileScp = fullfile(kaldiDir, sprintf('data/%s/wav.scp', dataset));
noisyIdToFileMap = makeIdToFileMap(noisyIdToFileScp, true);

processAsrData(noisyLines, gtLines, noisyIdToFileMap, modelName, resDir, @noisyToCleanId);



function cleanId = noisyToCleanId(noisyId)
% Map a noisy file ID to a clean file ID.  A noisy file ID has an extra
% string followed by an underscore before the actual GRID file name.  So we
% just chop that off here.
cleanId = regexprep(noisyId, '^.*?_', '');


function gtLines = deriveGtLines(noisyLines)
% Derive the ground truth transcript of each file on each line from its
% file name.  The format of the filename is 'verb color prep letter number
% adv'

verbs = struct('fb', 'BIN', 'fl', 'LAY', 'fp', 'PLACE', 'fs', 'SET');
colors = struct('fb', 'BLUE', 'fg', 'GREEN', 'fr', 'RED', 'fw', 'WHITE');
preps = struct('fa', 'AT', 'fb', 'BY', 'fi', 'IN', 'fw', 'WITH');
chars = struct('fa', 'A', 'fb', 'B', 'fc', 'C', 'fd', 'D', 'fe', 'E', ...
    'ff', 'F', 'fg', 'G', 'fh', 'H', 'fi', 'I', 'fj', 'J', 'fk', 'K', ...
    'fl', 'L', 'fm', 'M', 'fn', 'N', 'fo', 'O', 'fp', 'P', 'fq', 'Q', ...
    'fr', 'R', 'fs', 'S', 'ft', 'T', 'fu', 'U', 'fv', 'V', 'fw', 'W', ...
    'fx', 'X', 'fy', 'Y', 'fz', 'Z');
nums = struct('fz', 'ZERO', 'f1', 'ONE', 'f2', 'TWO', 'f3', 'THREE', ...
    'f4', 'FOUR', 'f5', 'FIVE', 'f6', 'SIX', 'f7', 'SEVEN', ...
    'f8', 'EIGHT', 'f9', 'NINE');
advs = struct('fa', 'AGAIN', 'fn', 'NOW', 'fp', 'PLEASE', 'fs', 'SOON');
mappings = {verbs, colors, preps, chars, nums, advs};

gtLines = cell(size(noisyLines));
for line = 1:length(noisyLines)
    fields = split(noisyLines{line}, ' ');
    id = fields{1};
    idParts = split(id, '_');
    gtChars = idParts{2};
    assert(length(gtChars) == length(mappings));
    
    words = cell(1, length(gtChars));
    for w = 1:length(gtChars)
        words{w} = mappings{w}.(['f' gtChars(w)]);
    end
    
    gtLines{line} = join([{id} words], ' ');

    if line < 5
        fprintf('NoisyLine%d: %s\n', line, noisyLines{line});
        fprintf('   GtLine%d: %s\n', line, gtLines{line});
    end
end
