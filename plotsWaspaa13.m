function plotsWaspaa13(toDisk, startAt)
    
% Make plots for WASPAA 2013 submission
    
if ~exist('toDisk', 'var') || isempty(toDisk), toDisk = false; end
if ~exist('startAt', 'var') || isempty(startAt), startAt = 0; end

prt('ToFile', toDisk, 'StartAt', startAt, ...
    'Width', 2, 'Height', 1.5, ...
    'TargetDir', '/home/mim/work/papers/waspaa13/pics', ...
    'SaveTicks', 1, 'Resolution', 200)

replacements = {'mim_', 'Expert ', ...
                'mTurk_', 'MTurk ', ...
                'helenWordsPad02_', 'Version 1 "', ...
                'helenWordsPad03_', 'Version 2 "', ...
                'helenWordsPad05_', 'Version 3 "', ...
                'vowelsM06_', '"', ...
                '.mat', '"', ...
                };

pcaDim = 31;

imCMap = easymap('bwr', 255);
dbCMap = easymap('wr', 255);

[files,paths] = findFiles('/home/data/mrt/features/', '.*\.mat', 1);

% Plot statistical intelligibility masks
for f = 1:length(files)
    m = load(paths{f});
    isRight = (m.fracRight >= 0.7) - (m.fracRight <= 0.3);
    %isRight = rand(size(m.fracRight)) <= m.fracRight;
    feat1 = m.features(isRight > 0,:);
    feat0 = m.features(isRight < 0,:);
    [h p isHigh] = tfCrossTab(sum(1-feat0), sum(1-feat1), ...
                              sum(feat0), sum(feat1));
    mat = reshape((2*isHigh-1).*exp(-p/.05), m.origShape);

    name = replaceStrs(files{f}, replacements);

    plotSpecgram(mat, m.fs, m.nFft, m.nFft/4, name, [-1 1], imCMap, ...
                 [1 1 1]);
    plotSpecgram(reshape(m.cleanFeat, m.origShape), m.fs, m.nFft, ...
                 m.nFft/4, [name '_spec'], [-80 10], dbCMap, [1 1 1]);
    
    rep = libLinearRep(m.pcaFeat, isRight, pcaDim);
    fullRep = reshape(-rep * m.pcs(:,1:pcaDim)', m.origShape);
    plotSpecgram(fullRep ./ max(fullRep(:)), m.fs, m.nFft, m.nFft/4, ...
                 [name '_svm'], [-1 1], imCMap, [1 1 1]); 
end



function plotSpecgram(X, fs, nFft, hop, name, cax, cmap, labels)

if size(X,1) == nFft/2+1
    f_khz = freqAxis_khz(nFft, fs);
    ylab = 'Frequency (kHz)';
else
    f_khz = 1:size(X,1);
    ylab = 'Coefficient';
end
t_ms = (0:size(X,2)-1) * hop / fs * 1000;

colormap(cmap)
imagesc(t_ms, f_khz, X)
caxis(cax)
axis xy
axis tight
title(replaceStrs(name, {'_spec', '', '_svm', ''}), 'interpreter', 'none')
if labels(1)
    ylabel(ylab)
else
    set(gca, 'YTickLabel', {});
end
if labels(2)
    xlabel('Time (ms)')
    xTickLabels = cellstr(get(gca, 'XTickLabel'));
    if strcmp(xTickLabels{1}, '0'), xTickLabels{1} = ''; end
    set(gca, 'XTickLabel', xTickLabels);
else
    set(gca, 'XTickLabel', {});
end
if labels(3)
    colorbar;
end

name = replaceStrs(name, {' ', '_', '''', '', '"', ''});
prt(name)


function f = freqAxis_khz(nFft, fs)
f = (0:nFft/2) / nFft * fs / 1000;


function s = replaceStrs(s, replacements)
% Repeatedly run strrep with pairs of values from cell array
% replacements
for i = 1:2:length(replacements)
    s = strrep(s, replacements{i}, replacements{i+1});
end


function rep = libLinearRep(Xtr, ytr, nDim)
Xtr = Xtr(:, 1:min(nDim,end));

keep = balanceSets(ytr, false, 22);
Xtr = Xtr(keep,:);
ytr = ytr(keep);

svm = linear_train(double(ytr), sparse(Xtr), '-s 2 -q');
sign = 2 * (svm.Label(1) < 0) - 1;
rep = sign * svm.w;
