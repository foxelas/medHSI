%======================================================================
%> @brief PlotOverlay applies a mask over a base image.
%>
%> @b Usage
%>
%> @code
%> plots.Overlay(fig, baseIm, topIm, figTitle);
%>
%> PlotOverlay(baseIm, topIm, figTitle, fig);
%> @endcode
%>
%> @param fig [int] | The figure handle
%> @param baseIm [numeric array] | The base image
%> @param topIm [numeric array] | The top image
%> @param figTitle [char] | The figure title
%======================================================================
function [] = PlotOverlay(baseIm, topIm, figTitle, fig)

hasTitle = ~isempty(figTitle);

imshow(imoverlay(baseIm, topIm, 'cyan'), 'InitialMagnification', 50);
if hasTitle
    title(figTitle);
end

plots.SavePlot(fig);

end
