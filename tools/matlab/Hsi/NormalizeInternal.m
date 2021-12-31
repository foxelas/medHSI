function normI = NormalizeInternal(Iin, Iwhite, Iblack, method)

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
        normI = (Iin - Iblack) ./ denom;

    otherwise
        error('Unsupported normalization method.');
end

if ~config.GetSetting('disableReflectranceExtremaPlots')
    %Need to draw mask 
    [mask, Iin_mask] = GetMaskFromFigureInternal(Iin);
    Iblack_mask = GetPixelsFromMaskInternal(Iblack, mask);
    Iwhite_mask = GetPixelsFromMaskInternal(Iwhite, mask);
    Inorm_mask = GetPixelsFromMaskInternal(normI, mask);
    x = hsiUtility.GetWavelengths(size(Iin_mask, 2));

    close all;
    figure(1);
    clf;
    hold on;
    plot(x, mean(reshape(Iwhite_mask, [size(Iwhite_mask, 1), size(Iwhite_mask, 2)])), 'DisplayName', 'Average White');
    plot(x, mean(reshape(Iblack_mask, [size(Iblack_mask, 1) , size(Iblack_mask, 2)])), 'DisplayName', 'Average Black');
    plot(x, mean(reshape(Iin_mask, [size(Iin_mask, 1) , size(Iin_mask, 2)])), 'DisplayName', 'Average Tissue');

    plot(x, min(reshape(Iwhite_mask, [size(Iwhite_mask, 1), size(Iwhite_mask, 2)])), 'DisplayName', 'Min White');
    plot(x, min(reshape(Iblack_mask, [size(Iblack_mask, 1) , size(Iblack_mask, 2)])), 'DisplayName', 'Min Black');
    plot(x, min(reshape(Iin_mask, [size(Iin_mask, 1) , size(Iin_mask, 2)])), 'DisplayName', 'Min Tissue');

    hold off; legend
    min(Iwhite_mask(:)-Iblack_mask(:))
    
    figure(2);
    hold on 
    for i = 1:size(Inorm_mask, 1)
        plot(x, Inorm_mask(i,:), 'g');
    end
    h = plot(x, mean(reshape(Inorm_mask, [size(Inorm_mask, 1), size(Inorm_mask, 2)])), 'DisplayName', 'Average Normalized', 'LineWidth', 3);
    hold off
    ylim([0,1]);
    xlim([420, 750]);
    legend(h);
 
end