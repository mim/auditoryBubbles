function genHtmlReference(outFile)

% Generate an HTML page with <audio> elements for playing clean s3 files

aCa = {'aba', 'ada', 'afa', 'aga', 'aja', 'aka', 'ama', 'ana', 'apa', 'asa', 'asha', 'ata', 'atha', 'athza', 'ava', 'aza'};
hVd = {'had', 'hawed', 'head', 'heed', 'hid', 'hod', 'hood', 'hud', 'who''d'};
Xin = {'din', 'fin', 'pin', 'sin', 'tin', 'win'};

aCaUrl = 'https://s3.amazonaws.com/mim.cse.osu/auditoryBubbles/20130423-bps15-snr-30/consonantsM1/';
hVdUrl = 'https://s3.amazonaws.com/mim.cse.osu/auditoryBubbles/20130514-newNoise2-bps10-snr-30/vowelsM06/';
XinUrl = 'https://s3.amazonaws.com/mim.cse.osu/auditoryBubbles/20130508-bps12-snr-35/helenWordsPad02/';

words = {aCa, hVd, Xin};
urls  = {aCaUrl, hVdUrl, XinUrl};
names = {'A-Consonant-A', 'H-Vowel-D', 'Consonant-IN'};

str = {};
str{end+1} = '<html><head><title>Reference recordings</title></head>';
str{end+1} = '<body><h1>Reference recordings</h1>';

audioStr = '<audio controls="controls" preload="auto"><source src="%s%s.wav" type="audio/wav" />Your browser does not support the HTML5 audio element.</audio>';
for s = 1:length(words)
    str{end+1} = sprintf('<h2>%s</h2><table>', names{s});
    for w = 1:length(words{s})
        str{end+1} = sprintf('<tr><td>%s</td><td>', words{s}{w});
        str{end+1} = sprintf(audioStr, urls{s}, words{s}{w});
        str{end+1} = '</td></tr>';
    end
    str{end+1} = '</table>';
end
str{end+1} = '</body></html>';

str = join(str, sprintf('\n'));
f = fopen(outFile, 'w');
fprintf(f, str);
fclose(f);
