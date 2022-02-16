function hsInorm = NormalizeInternal(hsIm, Iwhite, Iblack, method)

%% Normalize a given array I with max and min arrays, white and black
%  according to method 'method'
%
%   Usage:
%   normI = NormalizeImage(I, white, black, method)

eps = 0.000000001;
if nargin < 4
    method = 'scaling';
end

Iin = hsIm.Value;
[m, n, w] = size(Iin);
option = config.GetSetting('normalization');

switch option
    case 'byPixel'
        Iwhite = Iwhite;

    case 'uniSpectrum'
        Iwhite = reshape(repmat(Iwhite, m*n, 1), m, n, w);

    case 'bandmax'
        Iwhite = reshape(repmat(Iwhite, m*n, 1), m, n, w);

    case 'raw'
        method = 'raw';

    otherwise
        error('Unsupported setting for normalization.');
end

switch method
    case 'scaling'
        denom = Iwhite - Iblack;
        denom(denom <= 0) = eps;
        Inorm = (Iin - Iblack) ./ denom;

    case 'raw'
        Inorm = Iin;

    otherwise
        error('Unsupported normalization method.');
end

hsInorm = hsi(Inorm, false);
hsInorm.FgMask = hsIm.FgMask;

if ~config.GetSetting('disableReflectranceExtremaPlots')
    fig = 1;
    plots.NormalizationCheck(fig, hsIm, Iblack, Iwhite, hsInorm);
end

hsInorm = hsInorm.Max(0);
hsInorm = hsInorm.Update(hsInorm.IsNan(), 0);
hsInorm = hsInorm.Update(hsInorm.IsInf(), 0);

end