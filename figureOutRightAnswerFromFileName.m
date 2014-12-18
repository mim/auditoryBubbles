function word = figureOutRightAnswerFromFileName(fileName)

% For bubble noise files. Everything up to the first '_'.

[~,f] = fileparts(fileName);
parts = split(f, '_');
word = parts{1};
