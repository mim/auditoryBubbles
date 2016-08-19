function peaks = pickPeaks2D(H, I, smoothI, smoothJ, scaleI, scaleJ, vis)

if ~exist('scaleJ', 'var') || isempty(scaleJ), scaleJ = 1:size(H,2); end
if ~exist('scaleI', 'var') || isempty(scaleI), scaleI = 1:size(H,1); end
if ~exist('smoothI', 'var') || isempty(smoothI), smoothI = 10; end
if ~exist('smoothJ', 'var') || isempty(smoothJ), smoothJ = 4; end
if ~exist('vis', 'var') || isempty(vis), vis = 0; end

% Smooth the histogram
ker = gausswin(smoothI) * gausswin(smoothJ)';
H = conv2(H, ker, 'same');

if vis
  subplot 121, imagesc(scaleJ,scaleI,H), axis xy, colorbar
  drawnow
end

% Find peaks in the smoothed histogram
peaks = zeros(I,2);
for i=1:I
  [m,row,col] = max2(H);
  peaks(i,:) = [scaleJ(col) scaleI(row)];

  [jj ii] = meshgrid(scaleJ, scaleI);
  Z = ((jj - col).^2 / smoothJ.^2 + (ii - row).^2 / smoothI.^2 <= 1);
  H(Z) = nan;
  
%   Z = peak2gauss(H, row, col, size(ker)*2);
%   H = H - Z;
%   % H = H .* (H > 0);

  if vis
    subplot 122, imagesc(scaleJ,scaleI,Z), axis xy, colorbar
    subplot 121, imagesc(scaleJ,scaleI,H), axis xy, colorbar
    pause(1)
  end
end
