%======================================================================
%> @brief PlotSuperpixels plots superpixel labels
%>
%> @b Usage
%>
%> @code
%> plots.Superpixels(fig, baseImage, labels, 'Superpixel Boundary of image 3', 'boundary', []);
%>
%> plots.Superpixels(fig, baseImage, labels, 'Superpixels of image 3', 'color', fgMask);
%> @endcode
%>
%> @param fig [int] | The figure handle
%> @param baseIm [numeric array] | The base image
%> @param topIm [numeric array] | The top image
%> @param figTitle [char] | The figure title
%> @param plotType [char] | The plot type, either 'color' or 'boundary'
%> @param fgMask [numeric array] | The foreground mask
%======================================================================
function [] = PlotSuperpixels(baseIm, topIm, figTitle, plotType, fgMask, fig)
% PlotSuperpixels plots superpixel labels
%
% @b Usage
%
% @code
% plots.Superpixels(fig, baseImage, labels, 'Superpixel Boundary of image 3', 'boundary', []);
%
% plots.Superpixels(fig, baseImage, labels, 'Superpixels of image 3', 'color', fgMask);
% @endcode
%
% @param fig [int] | The figure handle
% @param baseIm [numeric array] | The base image
% @param topIm [numeric array] | The top image
% @param figTitle [char] | The figure title
% @param plotType [char] | The plot type, either 'color' or 'boundary'
% @param fgMask [numeric array] | The foreground mask
if ~isempty(plotType) && strcmpi(plotType, 'color') % isColor = 'color'
    topIm = topIm + 1; % To remove label 0, because labeloverlay ignores it
    topIm(~fgMask) = 0;
    B = labeloverlay(baseIm, topIm);
    imshow(B);

else % isColor = 'boundary'
    BW = boundarymask(topIm);
    imshow(imoverlay(baseIm, BW, 'cyan'), 'InitialMagnification', 50);
end

title(figTitle);
plots.SavePlot(fig);

end