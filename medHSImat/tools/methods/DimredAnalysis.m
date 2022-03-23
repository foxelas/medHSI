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
end

if strcmpi(method, 'rica')
    [~, scores, ~, ~, ~] = hsIm.Dimred('rica', varargin{:});
    subName = 'Reconstructed Component';
end

img = {srgb, squeeze(scores(:, :, 1)), squeeze(scores(:, :, 2)), squeeze(scores(:, :, 3))};
names = { strjoin({'SampleID: ', hsIm.SampleID}, {' '}) , strjoin({subName, '1'}, {' '}), strjoin({subName, '2'}, {' '}),  strjoin({subName, '3'}, {' '})};
plotPath = commonUtility.GetFilename('output', fullfile(config.GetSetting('saveFolder'), hsIm.ID, 'ica'), 'jpg');
plots.MontageCmap(1, plotPath, img, names, false);

pause(0.5);
end