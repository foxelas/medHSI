% ======================================================================
%> @brief NormalizeInternal a given hyperspectral image.
%>
%> The setting config::[Normalization] needs to be set beforehand.
%>
%> @b Usage
%>
%> @code
%> config.SetSetting('Normalization', 'byPixel');
%> [newI, idxs] = NormalizeInternal(I, Iwhite, Iblack, method);
%> @endcode
%>
%> @param obj [hsi] | An instance of the hsi class
%> @param white [numeric array] | The white reference image
%> @param black [numeric array] | The black reference image
%> @param method [string] | Optional: The normalization method ('scaling' or 'raw'). Default: 'scaling'
%>
%> @return instance of the hsi class
% ======================================================================
function hsInorm = NormalizeInternal(hsIm, Iwhite, Iblack, method)

if nargin < 4
    method = 'scaling';
end

Iin = hsIm.Value;
[m, n, w] = size(Iin);
option = config.GetSetting('Normalization');

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
        eps = 10^(-6);
        %         eps = abs(mean(denom, 'all'));
        denom(denom <= 0) = eps;
        Inorm = (Iin - Iblack) ./ denom;

    case 'raw'
        Inorm = Iin;

    otherwise
        error('Unsupported normalization method.');
end

hsInorm = hsIm;
hsInorm.Value = Inorm;

if ~config.GetSetting('DisableNormalizationCheck')
    plotPath = commonUtility.GetFilename('output', fullfile(config.GetSetting('NormCheckFolderName'), strcat(hsIm.ID, '_curves')), 'png');
    plots.NormalizationCheck(1, plotPath, hsIm, Iblack, Iwhite, hsInorm);
end

hsInorm = hsInorm.Max(0);
hsInorm = hsInorm.Update(hsInorm.IsNan(), 0);
hsInorm = hsInorm.Update(hsInorm.IsInf(), 0);

end