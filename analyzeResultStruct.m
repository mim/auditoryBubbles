function [outStruct keepKeys] = analyzeResultStruct(inStruct, filterBy, compareSrc, compareDst, compareField, ignoreFields)

% Analyze a structure array of results: filter, group, and compare fields
%
% outStruct = analyzeResultStruct(inStruct, filterBy, compareSrc, compareDst, compareField, ignoreFields)
%
% Inputs:
%   inStruct      structure array to be analyzed
%   filterBy      a structure with a subset of the fields in inStruct,
%                 elements of inStruct will be kept that match the
%                 corresponding values of filterBy
%   compareSrc    structure with field settings to match for first argument to minus
%   compareDst    structure with field settings to match for second argumen to minus
%   compareField  name of field to difference for comparison
%   ignoreFields  cell array of field names to ignore, otherwise fields
%                 besides compareField will be used in pairing up entries
%                 to compare them

if ~exist('ignoreFields', 'var'), ignoreFields = {}; end
% assert(all(strcmp(sort(fieldnames(compareSrc)), sort(fieldnames(compareDst)))), ...
%     'compareSrc and compareDst must have the same fields');
assert(~isSubStruct(compareSrc, compareDst))
assert(~isSubStruct(compareDst, compareSrc))
assert(isempty(intersect(fieldnames(compareSrc), fieldnames(filterBy))), ...
    'compareSrc/Dst must not share any fields with filterBy');

ignoreFields = union(union(union(ignoreFields, fieldnames(compareSrc)), fieldnames(compareDst)), {compareField});

keys = cell(size(inStruct));
foundVal = [0 0];
for p = 1:length(inStruct)
    if isSubStruct(inStruct(p), filterBy) && (isSubStruct(inStruct(p), compareSrc) || isSubStruct(inStruct(p), compareDst))
        keys{p} = makeKey(inStruct(p), ignoreFields);
        v = isSubStruct(inStruct(p), compareDst);
        foundVal(v + 1) = foundVal(v + 1) + 1;
    else
        keys{p} = '';
    end
end
assert(all(foundVal > 0))
assert(foundVal(1) == foundVal(2))

[~,ord] = sort(keys);
inStruct = inStruct(ord);
keys = keys(ord);

outStruct = [];
keepKeys = {};
for p = 1:2:length(inStruct)
    if isempty(keys{p}), continue; end
    assert(strcmp(keys{p}, keys{p+1}));
    outTmp = rmfield(inStruct(p), fieldnames(compareSrc));
    outTmp.(compareField) = str2double(inStruct(p).(compareField)) - str2double(inStruct(p+1).(compareField));
    if isSubStruct(inStruct(p), compareDst)
        outTmp.(compareField) = -outTmp.(compareField);
    end
    outStruct = [outStruct outTmp];
    keepKeys{end+1} = keys{p};
end


function s = isSubStruct(a, b)
% whether all fields of b are in a and all values of those fields are equal
fn = fieldnames(b);
s = true;
for f = 1:length(fn)
    s = s && isfield(a, fn{f}) && strcmp(a.(fn{f}), b.(fn{f}));
end

function key = makeKey(str, ignoreFields)
fn = sort(setdiff(fieldnames(str), ignoreFields));
for f=1:length(fn)
    kv{f} = sprintf('%s=%s', fn{f}, str.(fn{f}));
end
key = join(kv, ',');
