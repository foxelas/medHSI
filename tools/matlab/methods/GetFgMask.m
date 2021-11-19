function fgMask = GetFgMask(hsi)
%%GetFgMask returns the foreground mask for an image where background
%%pixels are black
%
%   Usage:
%   fgMask = GetFgMask(hsi);

if ndims(hsi) > 3
    srgb = GetDisplayImage(hsi, 'rgb');
else
    srgb = hsi;
end
fgMask = ~(squeeze(srgb(:, :, 1)) == 0 & squeeze(srgb(:, :, 1)) == 0 & squeeze(srgb(:, :, 1)) == 0);

end