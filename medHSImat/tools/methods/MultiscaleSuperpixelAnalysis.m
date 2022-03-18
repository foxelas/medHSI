% ======================================================================
%> @brief MultiscaleSuperpixelAnalysis applies Multiscale SuperPCA to an hsi and visualizes
%> the result.
%>
%> Needs SuperPCA package to work https://github.com/junjun-jiang/SuperPCA .
%>
%> Need to set config::[saveFolder] for image output.
%>
%> @b Usage
%>
%> @code
%> MultiscaleSuperpixelAnalysis(hsIm);
%>
%> apply.ToEach(@MultiscaleSuperpixelAnalysis, 20, 3);
%> @endcode
%>
%> @param hsIm [hsi] | An instance of the hsi class
%> @param labelInfo [hsiInfo] | An instance of the  hsiInfo class
%> @param pixelNumArray [numeric array] | The array of superpixels.
%> Default: [ 9, 14, 20, 28, 40].
%> @param pcNum [int] | The number of PCA components. Default: 3.
%>
%> @retval scores [cell array] | The PCA scores
%> @retval labels [cell array] | The labels of the superpixels
%> @retval validLabels [cell array] | The superpixel labels that refer
%> to tissue pixels
% ======================================================================
function [scores, labels, validLabels] = MultiscaleSuperpixelAnalysis(hsIm, labelInfo, varargin)
% MultiscaleSuperpixelAnalysis applies Multiscale SuperPCA to an hsi and visualizes
% the result.
%
% Needs SuperPCA package to work https://github.com/junjun-jiang/SuperPCA .
%
% Need to set config::[saveFolder] for image output.
%
% @b Usage
%
% @code
% MultiscaleSuperpixelAnalysis(hsIm);
%
% apply.ToEach(@MultiscaleSuperpixelAnalysis, 20, 3);
% @endcode
%
% @param hsIm [hsi] | An instance of the hsi class
% @param labelInfo [hsiInfo] | An instance of the  hsiInfo class
% @param pixelNumArray [numeric array] | The array of superpixels.
% Default: [ 9, 14, 20, 28, 40].
% @param pcNum [int] | The number of PCA components. Default: 3.
%
% @retval scores [cell array] | The PCA scores
% @retval labels [cell array] | The labels of the superpixels
% @retval validLabels [cell array] | The superpixel labels that refer
% to tissue pixels
close all;

if nargin < 2
    labelInfo = [];
end

savedir = commonUtility.GetFilename('output', fullfile(config.GetSetting('saveFolder'), config.GetSetting('fileName')), '');

%% Preparation
srgb = hsIm.GetDisplayImage('rgb');

[scores, labels, validLabels] = hsIm.MultiscaleSuperPCA(varargin{:});
pixelNumArray = floor(50*sqrt(2).^[-2:2]);

N = numel(scores);

pc1 = cell(N, 1);
pc2 = cell(N, 1);
pc3 = cell(N, 1);
names = cell(N, 1);
for i = 1:N
    names{i} = strjoin({'Superpixels:', num2str(pixelNumArray(i))}, {' '});
    labels{i} = labeloverlay(srgb, labels{i});
    pc1{i} = scores{i}(:, :, 1);
    pc2{i} = scores{i}(:, :, 2);
    pc3{i} = scores{i}(:, :, 3);
end

plotName = fullfile(savedir, 'superpixel_segments.jpg');
plots.Montage(1, labels, names, plotName);

plotName = fullfile(savedir, 'PC1.jpg');
plots.MontageCmap(2, pc1, names, plotName);

plotName = fullfile(savedir, 'PC2.jpg');
plots.MontageCmap(3, pc2, names, plotName);

plotName = fullfile(savedir, 'PC3.jpg');
plots.MontageCmap(4, pc3, names, plotName);

end
