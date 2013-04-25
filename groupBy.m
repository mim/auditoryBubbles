function grouped = groupBy(ca, colNum, varargin)

% Group a 2D cell array by the elements in one column
%
% grouped = groupBy(ca, colNum, [aggFn1, aggCol1, ...])
%
% Output is a cell array with the same number of columns as the input, one
% row per unique element in the specified column, and cell arrays of values
% in the other columns.  Optionally, a list of aggregation function and
% columns can be supplied where aggFn is a function handle that will be run
% on column number aggCol.  It should have the following interface:
%   colVal = aggFn(cellArrayOfValues);

[uniques,~,classes] = unique(ca(:,colNum));
grouped = cell(length(uniques), size(ca,2));
grouped(:,colNum) = uniques;

otherCols = setdiff(1:size(ca,2), colNum);
for r = 1:length(uniques)
    for c = otherCols
        grouped{r,c} = ca(r == classes, c);
    end
    for a = 1:2:length(varargin)
        aggFn  = varargin{a};
        aggCol = varargin{a+1};
        grouped{r,aggCol} = aggFn(grouped{r,aggCol});
    end
end
