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
function [scores, labels, validLabels] = SuperpixelAnalysis(hsIm, isManual, pixelNum, pcNum)
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
    isManual = false;
end

if nargin < 3
    pixelNum = 20;
end

if nargin < 4
    pcNum = 3;
end
savedir = commonUtility.GetFilename('output', fullfile(config.GetSetting('saveFolder'), config.GetSetting('fileName')), '');

%% Preparation
srgb = hsIm.GetDisplayImage('rgb');
fgMask = hsIm.FgMask;

%% Calculate superpixels
if isManual
    %%Apply PCA to entire image
    [coeff, scores, latent, explained, ~] = hsIm.Dimred('pca', pcNum, fgMask);
    explained(1:pcNum);
    latent(1:pcNum);

    % Use the 1st PCA component for superpixel calculation
    redImage = rescale(squeeze(scores(:, :, 1)));
    [labels, ~] = superpixels(redImage, pixelNum);

    % Keep only pixels that belong to the tissue (Superpixel might assign
    % background pixels also). The last label is background label.
    [labels, validLabels] = CleanLabels(labels, fgMask, pixelNum);

else
    %%super-pixels segmentation
    labels = hsIm.Cubseg(pixelNum);

    % Keep only pixels that belong to the tissue (Superpixel might assign
    % background pixels also). The last label is background label.
    [labels, validLabels] = CleanLabels(labels, fgMask, pixelNum);

    %%SupePCA based DR
    scores = hsIm.SPCA(pcNum, labels);
end

config.SetSetting('plotName', fullfile(savedir, 'superpixel_segments'));
plots.Superpixels(1, srgb, labels);
config.SetSetting('plotName', fullfile(savedir, 'superpixel_mask'));
plots.Superpixels(2, srgb, labels, '', 'color', fgMask);
config.SetSetting('plotName', fullfile(savedir, 'pc'));
plots.Components(scores, pcNum, 3);

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

% ======================================================================
%> @brief CleanLabels returns superpixel labels that contain tissue pixels.
%>
%> Keep only pixels that belong to the tissue (Superpixel might assign
%> background pixels also). The last label is background label.
%>
%> @b Usage
%>
%> @code
%> [cleanLabels, validLabels] = CleanLabels(labels, fgMask, pixelNum);
%> @endcode
%>
%> @param labels [numeric array] | The labels of the superpixels
%> @param fgMask [numeric array] | The foreground mask
%> @param pixelNum [int] | The number of superpixels.
%>
%> @retval cleanLabels [numeric array] | The labels of the superpixels
%> @retval validLabels [numeric array] | The superpixel labels that refer
%> to tissue pixels
% ======================================================================
function [cleanLabels, validLabels] = CleanLabels(labels, fgMask, pixelNum)
% CleanLabels returns superpixel labels that contain tissue pixels.
%
% Keep only pixels that belong to the tissue (Superpixel might assign
% background pixels also). The last label is background label.
%
% @b Usage
%
% @code
% [cleanLabels, validLabels] = CleanLabels(labels, fgMask, pixelNum);
% @endcode
%
% @param labels [numeric array] | The labels of the superpixels
% @param fgMask [numeric array] | The foreground mask
% @param pixelNum [int] | The number of superpixels.
%
% @retval cleanLabels [numeric array] | The labels of the superpixels
% @retval validLabels [numeric array] | The superpixel labels that refer
% to tissue pixels

labels(~fgMask) = pixelNum;

pixelLim = 10;
labelTags = unique(labels)';
labelTags = labelTags(labelTags ~= pixelNum); % Remove last label (background pixels)
validLabels = [];
k = 0;

for i = labelTags
    sumPixel = sum(labels == i, 'all');
    if sumPixel < pixelLim %Ignore superpixel labels with too few pixels
        labels(labels == i) = pixelNum;
    else
        k = k + 1;
        validLabels(k) = i;
    end
end

cleanLabels = labels;
end
