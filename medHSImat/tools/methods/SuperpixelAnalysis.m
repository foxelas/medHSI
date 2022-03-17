% ======================================================================
%> @brief SuperpixelAnalysis applies SuperPCA to an hsi and visualizes
%> the result.
%>
%> Need to set config::[saveFolder] for image output.
%>
%> @b Usage
%>
%> @code
%> SuperpixelAnalysis(hsIm);
%>
%> apply.ToEach(@SuperpixelAnalysis, true, 20, 3);
%> @endcode
%>
%> @param hsIm [hsi] | An instance of the hsi class
%> @param labelInfo [hsiInfo] | An instance of the  hsiInfo class
%> @param isManual [boolean] | A  flag to show whether is manual (local)
%> implementation or by SuperPCA package. Default: false.
%> @param pixelNum [int] | The number of superpixels. Default: 20.
%> @param pcNum [int] | The number of PCA components. Default: 3.
%>
%> @retval scores [numeric array] | The PCA scores
%> @retval labels [numeric array] | The labels of the superpixels
%> @retval validLabels [numeric array] | The superpixel labels that refer
%> to tissue pixels
% ======================================================================
function [scores, labels, validLabels] = SuperpixelAnalysis(hsIm, labelInfo, varargin)
% SuperpixelAnalysis applies SuperPCA to an hsi and visualizes
% the result.
%
% Need to set config::[saveFolder] for image output.
%
% @b Usage
%
% @code
% SuperpixelAnalysis(hsIm);
%
% apply.ToEach(@SuperpixelAnalysis, true, 20, 3);
% @endcode
%
% @param hsIm [hsi] | An instance of the hsi class
% @param labelInfo [hsiInfo] | An instance of the  hsiInfo class
% @param isManual [boolean] | A  flag to show whether is manual (local)
% implementation or by SuperPCA package. Default: false.
% @param pixelNum [int] | The number of superpixels. Default: 20.
% @param pcNum [int] | The number of PCA components. Default: 3.
%
% @retval scores [numeric array] | The PCA scores
% @retval labels [numeric array] | The labels of the superpixels
% @retval validLabels [numeric array] | The superpixel labels that refer
% to tissue pixels

if nargin < 2 
    labelInfo = [];
end

savedir = commonUtility.GetFilename('output', fullfile(config.GetSetting('saveFolder'), config.GetSetting('fileName')), '');

%% Preparation
srgb = hsIm.GetDisplayImage('rgb');
fgMask = hsIm.FgMask;

[scores, labels, validLabels] = hsIm.SuperPCA(varargin{:});

config.SetSetting('plotName', fullfile(savedir, 'superpixel_segments'));
plots.Superpixels(1, srgb, labels);
config.SetSetting('plotName', fullfile(savedir, 'superpixel_mask'));
plots.Superpixels(2, srgb, labels, '', 'color', fgMask);
config.SetSetting('plotName', fullfile(savedir, 'pc'));
plots.Components(scores, 3);

if config.GetSetting('showFigures')
    pause(0.5);

    %% Plot eigenvectors
    numComp = 3;

    Xcol = hsIm.GetMaskedPixels(fgMask);
    wavelengths = hsiUtility.GetWavelengths(size(Xcol, 2));
    basename = fullfile(savedir, 'eigenvectors');
    config.SetSetting('plotName', basename);
    coeff = Dimred(Xcol, 'pca', numComp);
    plots.Eigenvectors(6, coeff, wavelengths, numComp);
    for i = validLabels
        superpixelMask = labels == i;
        Xcol = hsIm.GetMaskedPixels(superpixelMask);
        coeff = Dimred(Xcol, 'pca', numComp);
        config.SetSetting('plotName', strcat(basename, num2str(i)));
        plots.Eigenvectors(6, coeff, wavelengths, numComp);
        title(strcat('Eigenvectors for Superpixel #', num2str(i)));
        plots.SavePlot(6);
        pause(0.5);
    end

    %% Plot statistics
    statistic = 'covariance';
    basename = fullfile(savedir, statistic);
    config.SetSetting('plotName', basename);
    plots.BandStatistics(7, Xcol, statistic);

    for i = validLabels
        superpixelMask = labels == i;
        Xcol = hsIm.GetMaskedPixels(superpixelMask);
        config.SetSetting('plotName', strcat(basename, num2str(i)));
        plots.BandStatistics(7, Xcol, statistic);
        title(strcat('Covariance for Superpixel #', num2str(i)));
        plots.SavePlot(7);
        pause(0.5);
    end
end
end

