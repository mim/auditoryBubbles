function [grouped digested] = loadProcessedAsrData(inCsvFile, outGroupedFile)

% Like processAsrData, but just load pre-processed CSV file output by
% amiResultsForBubbles.py

grouped = csvReadCells(inCsvFile);
grouped(:,5) = listMap(@str2double, grouped(:,5));

digested = grouped;
gtWordsNow = grouped(1,6);

equivClasses = [];
responseCounts = nan*ones(size(grouped,1),1);
cleanId = '';

ensureDirExists(outGroupedFile);
save(outGroupedFile, 'grouped', 'digested', 'gtWordsNow', 'cleanId', 'equivClasses', 'responseCounts');
