% ======================================================================
%> @brief RemoveBackgroundInternal returns the foreground mask for a sample.
%>
%> The foreground mask corresponds to the tensors that belong to
%> the tissue.
%> See also
%> https://www.mathworks.com/help/images/color-based-segmentation-using-k-means-clustering.html.
%>
%> @b Usage
%>
%> @code
%> hsIm = RemoveBackgroundInternal(I, colorLevelsForKMeans, attemptsForKMeans, layerSelectionThreshold, bigHoleCoefficient, closingCoefficient, openingCoefficient);
%> @endcode
%>
%> @param obj [hsi] | An instance of the hsi class
%> @b Optional varargin
%> @param colorLevelsForKMeans [int] | Color levels for Kmeans. Default is 6.
%> @param attemptsForKMeans [int] | Attempts for Kmeans. Default is 3.
%> @param layerSelectionThreshold [double] | Threshold for layer
%> selection. Default is 0.1.
%> @param bigHoleCoefficient [double] | Coefficient for closing big holes. Default is 1000
%> @param closingCoefficient [double] | Coefficient for closing operation. Default is 2.
%> @param openingCoefficient [double] | Coefficient for opening operation. Default is 5.
%>
%> @retval fgMask [numeric array] | A foreground mask
% ======================================================================
function [updI, fgMask] = RemoveBackgroundInternal(I, colorLevelsForKMeans, attemptsForKMeans, layerSelectionThreshold, bigHoleCoefficient, closingCoefficient, openingCoefficient)
% RemoveBackgroundInternal returns the foreground mask for a sample.
%
% The foreground mask corresponds to the tensors that belong to
% the tissue.
% See also
% https://www.mathworks.com/help/images/color-based-segmentation-using-k-means-clustering.html.
%
% @b Usage
%
% @code
% hsIm = RemoveBackgroundInternal(I, colorLevelsForKMeans, attemptsForKMeans, layerSelectionThreshold, bigHoleCoefficient, closingCoefficient, openingCoefficient);
% @endcode
%
% @param obj [hsi] | An instance of the hsi class
% @b Optional varargin
% @param colorLevelsForKMeans [int] | Color levels for Kmeans. Default is 6.
% @param attemptsForKMeans [int] | Attempts for Kmeans. Default is 3.
% @param layerSelectionThreshold [double] | Threshold for layer
% selection. Default is 0.1.
% @param bigHoleCoefficient [double] | Coefficient for closing big holes. Default is 1000
% @param closingCoefficient [double] | Coefficient for closing operation. Default is 2.
% @param openingCoefficient [double] | Coefficient for opening operation. Default is 5.
%
% @retval fgMask [numeric array] | A foreground mask
[m, n, z] = size(I);
if z > 3
    Irgb = GetDisplayImageInternal(I, 'rgb');
else
    Irgb = I;
end

if (nargin < 2)
    colorLevelsForKMeans = 6;
end
if (nargin < 3)
    attemptsForKMeans = 3;
end
if (nargin < 4)
    layerSelectionThreshold = 0.1;
end
if (nargin < 5)
    bigHoleCoefficient = 100;
end
if (nargin < 6)
    closingCoefficient = 2;
end
if (nargin < 7)
    openingCoefficient = 5;
end


lab_he = rgb2lab(Irgb);
%     figure(1);
%     imshow(lab_he);
ab = lab_he(:, :, 2:3);
ab = im2single(ab);

% repeat the clustering 3 times to avoid local minima
pixel_labels = imsegkmeans(ab, colorLevelsForKMeans, 'NumAttempts', attemptsForKMeans);
%     figure(13);
%     imshow(pixel_labels,[])
%     title('Image Labeled by Cluster Index');

bgCounts = zeros(1, colorLevelsForKMeans);
for jj = 1:colorLevelsForKMeans
    %         figure(jj+2); %%
    maskjj = pixel_labels == jj;
    bgCounts(jj) = sum(sum(maskjj(1:m, 1:10))) + sum(sum(maskjj(1:10, 1:n)));
    %         imshow(maskjj); %%
end
%bgCounts
bgCounts(bgCounts <= (max(bgCounts) * layerSelectionThreshold)) = 0; %%
[~, bgChannels] = sort(bgCounts, 'descend');
bgChannels = bgChannels(bgCounts(bgChannels) > 0); %%
fgMask = ~ismember(pixel_labels, bgChannels);

diam = ceil(min(m, n)*0.005); %%
fgMask = imclose(fgMask, strel('disk', diam*closingCoefficient, 4));

fgMask = closeSmallHolesInTheBackground(fgMask, diam*bigHoleCoefficient);

fgMaskBase = imfill(fgMask, 8, 'holes');
fgMask = imopen(fgMaskBase, strel('disk', diam*openingCoefficient, 4));

%Threshold so that masks should be larger than 30 pixels
if sum(fgMask(:)) < 30
    fgMask = fgMaskBase;
else
    fgMask = bwareaopen(fgMask, ceil(m*n/500), 8);
    %specimenMask = imopen(specimenMask,strel('disk',diam * openingCoefficient,4));
    % cluster1 = Irgb .* double(specimenMask);
end

if config.GetSetting('showFigures')
    filepath = config.DirMake(config.GetSetting('outputDir'), config.GetSetting('backgroundRemoval'), ...
        config.GetSetting('database'), strcat(config.GetSetting('fileName'), '.jpg'));
    config.SetSetting('plotName', filepath);
    plots.Overlay(1, Irgb, fgMask);
end

updI = I .* repmat(double(fgMask), [1, 1, z]);

end

function imageWithoutSmallHoles = closeSmallHolesInTheBackground(image, bigHoleDiameter)
filled = imfill(~image, 'holes');
holes = filled & image;
bigholes = bwareaopen(holes, bigHoleDiameter);
smallholes = holes & ~bigholes;
imageWithoutSmallHoles = ~(~image | smallholes);
end
