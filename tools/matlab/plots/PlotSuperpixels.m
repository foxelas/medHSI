function [] = PlotSuperpixels(baseImage, superpixelInfo, figTitle, fig)
% PlotSuperpixels plots the results of superpixel segmentation on the image
%
%   Usage:
%   PlotSuperpixels(baseImage, L, 'Superpixels of image 3', 1);

BW = boundarymask(superpixelInfo);
imshow(imoverlay(baseImage, BW, 'cyan'), 'InitialMagnification', 67);
title(figTitle);
% SavePlot(fig);

end