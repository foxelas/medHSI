function [scores] = DimredAnalysis(hsIm, labelInfo, method, varargin)

if nargin < 2
    labelInfo = [];
end

close all;

%% Preparation
srgb = hsIm.GetDisplayImage('rgb');

if strcmpi(method, 'ica')
    [~, scores, ~, ~, ~] = hsIm.Dimred('ica', varargin{:});
    subName = 'Independent Component';
    limitVal = [];
end

if strcmpi(method, 'rica')
    [~, scores, ~, ~, ~] = hsIm.Dimred('rica', varargin{:});
    subName = 'Reconstructed Component';
    limitVal = [[0,0]; [-3, 3]; [-1, 1]; [-15,0]];
end

if strcmpi(method, 'pca')
    [~, scores, ~, ~, ~] = hsIm.Dimred('pca', varargin{:});
    subName = 'Principal Component';
    limitVal =  [[0,0]; [-3, 10]; [-3, 3]; [-1,1]];
end


img = {srgb, squeeze(scores(:, :, 1)), squeeze(scores(:, :, 2)), squeeze(scores(:, :, 3))};
names = {labelInfo.Diagnosis, strjoin({subName, '1'}, {' '}), strjoin({subName, '2'}, {' '}),  strjoin({subName, '3'}, {' '})};
plotPath = commonUtility.GetFilename('output', fullfile(config.GetSetting('saveFolder'), hsIm.ID, 'ica'), 'png');
plots.MontageCmap(1, plotPath, img, names, false, limitVal);

img = {srgb, squeeze(scores(:, :, 1)), squeeze(scores(:, :, 2)), squeeze(scores(:, :, 3))};
names = {labelInfo.Diagnosis, strjoin({subName, '1'}, {' '}), strjoin({subName, '2'}, {' '}),  strjoin({subName, '3'}, {' '})};
plotPath = commonUtility.GetFilename('output', fullfile(config.GetSetting('saveFolder'), hsIm.ID, 'ica_overlay'), 'png');
plots.MontageWithLabel(2, plotPath, img, names, labelInfo.Labels, hsIm.FgMask);


pause(0.5);
end