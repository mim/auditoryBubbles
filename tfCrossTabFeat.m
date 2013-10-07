function mat = tfCrossTabFeat(fileName, pThresh)

% Analyze a file saved by collectFeatures using tfCrossTab
%
% mat = tfCrossTabFeat(fileName, pThresh)

if ~exist('pThresh', 'var') || isempty(pThresh), pThresh = 0.05; end

m = load(fileName);
isRight = (m.fracRight >= 0.7) - (m.fracRight <= 0.3);
%isRight = rand(size(m.fracRight)) <= m.fracRight;
feat1 = m.features(isRight > 0,:);
feat0 = m.features(isRight < 0,:);
[~,p,isHigh] = tfCrossTab(sum(1-feat0), sum(1-feat1), sum(feat0), sum(feat1));
mat = reshape((2*isHigh-1).*exp(-p/pThresh), m.origShape);
