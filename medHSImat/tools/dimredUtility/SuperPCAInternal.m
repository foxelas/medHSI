% ======================================================================
%> @brief SuperPCA applies SuperPCA to an hsi object.
%>
%> Needs SuperPCA package to work https://github.com/junjun-jiang/SuperPCA .
%>
%> @b Usage
%>
%> @code
%> [scores, labels, validLabels] = dimredUtility.SuperPCA(hsIm);
%>
%> [scores, labels, validLabels] = dimredUtility.SuperPCA(hsIm, isManual, pixelNum, pcNum);
%> @endcode
%>
%> @param hsIm [hsi] | An instance of the hsi class
%> @param isManual [boolean] | Optional: A  flag to show whether is manual (local)
%> implementation or by SuperPCA package. Default: false.
%> @param pixelNum [int] | Optional: The number of superpixels. Default: 20.
%> @param pcNum [int] | Optional: The number of PCA components. Default: 3.
%>
%> @retval scores [numeric array] | The PCA scores
%> @retval labels [numeric array] | The labels of the superpixels
%> @retval validLabels [numeric array] | The superpixel labels that refer
%> to tissue pixels
% ======================================================================
function [scores, labels, validLabels] = SuperPCAInternal(obj, isManual, pixelNum, pcNum)

if nargin < 2
    isManual = false;
end

if nargin < 3
    pixelNum = 20;
end

if nargin < 4
    pcNum = 3;
end

fgMask = obj.FgMask;

%% Calculate superpixels
if isManual
    %%Apply PCA to entire image
    [~, scores, latent, explained, ~] = obj.Dimred('pca', pcNum, fgMask);
    %                 explained(1:pcNum);
    %                 latent(1:pcNum);

    % Use the 1st PCA component for superpixel calculation
    redImage = rescale(squeeze(scores(:, :, 1)));
    [labels, ~] = superpixels(redImage, pixelNum);

    scores = SuperPCA(obj.Value, pcNum, labels);

    % Keep only pixels that belong to the tissue (Superpixel might assign
    % background pixels also). The last label is background label.
    [labels, validLabels] = hsiUtility.CleanLabels(labels, fgMask, pixelNum);

else
    %%super-pixels segmentation
    labels = cubseg(obj.Value, pixelNum);

    % Keep only pixels that belong to the tissue (Superpixel might assign
    % background pixels also). The last label is background label.
    [labels, validLabels] = hsiUtility.CleanLabels(labels, fgMask, pixelNum);

    %%SupePCA based DR
    scores = SuperPCA(obj.Value, pcNum, labels);
end

end