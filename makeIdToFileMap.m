function idToFileMap = makeIdToFileMap(idToFileList, resolveSymlinks)
% Create a struct with keys idXXXXXXXX mapping a noisy file ID to an
% absolute file path

if ~exist('resolveSymlinks', 'var') || isempty(resolveSymlinks), resolveSymlinks = false; end

lines = textArray(idToFileList);
idToFileMap = struct();
for i = 1:length(lines)
    if isempty(lines{i}), continue; end
    
    fields = split(lines{i}, ' ');
    key = ['id' fields{1}];
    val = join(fields(2:end), ' ');

    if resolveSymlinks
      val = realpath(val);
    end

    idToFileMap.(key) = val;
end

