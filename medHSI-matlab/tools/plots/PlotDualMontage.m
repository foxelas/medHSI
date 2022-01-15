function [] = PlotDualMontage(left, right, figTitle, fig)
% PlotDualMontage Plots two images side by side
%
%   Usage:
%   PlotDualMontage(left, right, figTitle, fig)

hasTitle = true;
if nargin < 4
    hasTitle = isnumeric(figTitle);
    if ~hasTitle
        fig = figTitle;
        figTitle = '';
    end
end

warning('off');

imshowpair(left, right, 'montage');
if hasTitle
    title(figTitle);
end
pause(0.1)
SavePlot(fig);

warning('on');
end
