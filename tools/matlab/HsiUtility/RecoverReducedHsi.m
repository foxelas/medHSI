function [outHsi] = RecoverReducedHsi(redHsi, origSize, mask)
% RecoverReducedHsi returns an image that matches the spatial dimensions
%   of the original hsi
%
%   Usage:
%   [outHsi] = RecoverReducedHsi(redHsi, origSize, mask)

m = origSize(1);
n = origSize(2);
q = size(redHsi, 2);

isMasked = nargin >= 3;
if isMasked
    outHsi = zeros(m, n, q);
    outHsiFlat = reshape(outHsi, [m * n, q]);
    maskFlat = reshape(mask, [m * n, 1]);
    outHsiFlat(maskFlat, :) = redHsi;
else
    outHsiFlat = redHsi;
end

outHsi = reshape(outHsiFlat, [m, n, q]);

end