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

close all;

%% Preparation
srgb = hsIm.GetDisplayImage();
fgMask = hsIm.FgMask;

[scores, labels, validLabels] = hsIm.SuperPCA(varargin{:});

img = {srgb, squeeze(scores(:, :, 1)), squeeze(scores(:, :, 2)), squeeze(scores(:, :, 3))};
names = { labelInfo.Diagnosis, 'Principal Component 1', 'Principal Component 2', 'Principal Component 3'};
plotPath = fullfile(savedir, 'spca-cmap');
plots.MontageCmap(1, plotPath, img, names, false);


img = {srgb, squeeze(scores(:, :, 1)), squeeze(scores(:, :, 2)), squeeze(scores(:, :, 3))};
names = { labelInfo.Diagnosis , 'Principal Component 1', 'Principal Component 2', 'Principal Component 3'};
plotPath = fullfile(savedir, 'spca');
plots.MontageWithLabel(1, plotPath, img, names, labelInfo.Labels, hsIm.FgMask);

plotPath = fullfile(savedir, 'superpixel_segments');
plots.Superpixels(2, plotPath, srgb, labels);
plotPath = fullfile(savedir, 'superpixel_mask');
plots.Superpixels(3, plotPath, srgb, labels, '', 'color', fgMask);
plotBasePath = fullfile(savedir, 'pc');
plots.Components(scores, 3, 4, plotBasePath);

pause(0.5);

if config.GetSetting('isTest')
    pause(0.5);

    %% Plot eigenvectors
    numComp = 3;

    Xcol = hsIm.GetMaskedPixels(fgMask);
    wavelengths = hsiUtility.GetWavelengths(size(Xcol, 2));
    basePath = fullfile(savedir, 'eigenvectors');
    coeff = Dimred(Xcol, 'pca', numComp);
    plots.Eigenvectors(7, basePath, coeff, wavelengths, numComp, 'Eigenvectors for the entire image');
    for i = validLabels
        superpixelMask = labels == i;
        Xcol = hsIm.GetMaskedPixels(superpixelMask);
        coeff = Dimred(Xcol, 'pca', numComp);
        figTitle = strcat('Eigenvectors for Superpixel #', num2str(i));
        plots.Eigenvectors(7, strcat(basePath, num2str(i)), coeff, wavelengths, numComp, figTitle);
    end

    %% Plot statistics
    statistic = 'covariance';
    basePath = fullfile(savedir, statistic);
    figTitle = 'Covariance for the entire image';
    plots.BandStatistics(8, basePath, Xcol, statistic, figTitle);

    for i = validLabels
        superpixelMask = labels == i;
        Xcol = hsIm.GetMaskedPixels(superpixelMask);
        figTitle = strcat('Covariance for Superpixel #', num2str(i));
        plots.BandStatistics(8, strcat(basePath, num2str(i)), Xcol, statistic, figTitle);
    end

    criteria = 'eigenvectors*.jpg';
    plots.MontageFolderContents(9, strcat(savedir, '\'), criteria, 'Eigenvectors for each superpixel', [800, 800]);
end
end
