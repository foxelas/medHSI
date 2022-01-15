function fgMask = GetFgMaskInternal(hsIm)
%%GetFgMask returns the foreground mask for an image where background
%%pixels are black
%
%   Usage:
%   fgMask = GetFgMask(hsIm);

if ndims(hsIm) > 3
    srgb = GetDisplayImage(hsIm, 'rgb');
else
    srgb = hsIm;
end
fgMask = ~(squeeze(srgb(:, :, 1)) == 0 & squeeze(srgb(:, :, 1)) == 0 & squeeze(srgb(:, :, 1)) == 0);

end