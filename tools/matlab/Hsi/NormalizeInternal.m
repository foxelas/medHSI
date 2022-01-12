function Inorm = NormalizeInternal(Iin, Iwhite, Iblack, method)

%% Normalize a given array I with max and min arrays, white and black
%  according to method 'method'
%
%   Usage:
%   normI = NormalizeImage(I, white, black, method)

if nargin < 4
    method = 'scaling';
end

switch method
    case 'scaling'
        denom = Iwhite - Iblack;
        denom(denom <= 0) = 0.000000001;
        Inorm = (Iin - Iblack) ./ denom;

    otherwise
        error('Unsupported normalization method.');
end

if ~config.GetSetting('disableReflectranceExtremaPlots')
    fig = 1;
    plots.NormalizationCheck(fig, Iin, Iblack, Iwhite, Inorm);
end

end