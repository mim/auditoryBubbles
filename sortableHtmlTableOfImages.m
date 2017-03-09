function sortableHtmlTableOfImages(plotsDir, plotType)

% Create a sortable HTML table of results images.  One column of the table
% wil be created for each underscore-delimited field in the name of the
% directory plus file.

if ~exist('plotType', 'var') || isempty(plotType), plotType = 'onSpecTr1'; end

[~,files] = findFiles(plotsDir, [plotType '.png'], 1, ['^' plotType]);

outDir = fullfile(plotsDir, plotType);
if ~exist(outDir, 'dir'), mkdir(outDir); end

% Copy files to new directory
for f = 1:length(files)
    dirs = split(files{f}, filesep);
    newFileNames{f} = [dirs{end-1} '_' dirs{end}];
    outFile = fullfile(outDir, newFileNames{f});
    copyfile(files{f}, outFile);
end

% Create HTML
htmlFile = fullfile(outDir, 'index.html');
f = fopen(htmlFile, 'w');
fprintf(f, '<html>\n');
fprintf(f, ['<head>' ...
    '<link rel="stylesheet" type="text/css" href="http://cdn.datatables.net/1.10.13/css/jquery.dataTables.css">  ' ...
    '<script src="http://code.jquery.com/jquery-1.12.4.js"></script> ' ...
    '<script type="text/javascript" charset="utf8" src="http://cdn.datatables.net/1.10.13/js/jquery.dataTables.js"></script> ' ...
    '</head>']);
fprintf(f, '<table id="imgs" class="display">\n<thead>');
fields = split(newFileNames{1}, '_');
for fi = 1:length(fields)
    fprintf(f, '<th>Field %d</th>', fi);
end
fprintf(f, '<th></th></thead>\n<tbody>');
for i = 1:length(files)
    fields = split(newFileNames{i}, '_');
    fprintf(f, '<tr>');
    for fi = 1:length(fields)
        fprintf(f, '<td>%s</td>', fields{fi});
    end
    fprintf(f, '<td><img src="%s" height="150" /></td></tr>\n', newFileNames{i});
end
fprintf(f, ['</tbody></table>\n<script>' ...
    '$(document).ready( function () {\n' ...
    '    $("#imgs").DataTable();\n' ...
    '} );\n' ...
    '</script></body>\n</html>\n']);
fclose(f);
