function [scores] = DimredAnalysis(hsIm, labelInfo, method, varargin)

if nargin < 2
    labelInfo = [];
end

close all;

%% Preparation
srgb = hsIm.GetDisplayImage('rgb');

if strcmpi(method, 'ica')
    [coeff, scores, ~, explained, ~] = hsIm.Dimred('ica', varargin{:});
    subName = 'Independent Component';
    limitVal = [];
end

if strcmpi(method, 'rica')
    [coeff, scores, ~, explained, ~] = hsIm.Dimred('rica', varargin{:});
    subName = 'Reconstructed Component';
    limitVal = [[0, 0]; [-3, 3]; [-1, 1]; [-15, 0]];
end

if strcmpi(method, 'pca')
    [coeff, scores, ~, explained, ~] = hsIm.Dimred('pca', varargin{:});
    subName = 'Principal Component';
    limitVal = [[0, 0]; [-3, 10]; [-3, 3]; [-1, 1]];
end


img = {srgb, squeeze(scores(:, :, 1)), squeeze(scores(:, :, 2)), squeeze(scores(:, :, 3))};
names = {labelInfo.Diagnosis, strjoin({subName, '1'}, {' '}), strjoin({subName, '2'}, {' '}), strjoin({subName, '3'}, {' '})};
plotPath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), hsIm.ID, 'ca'), 'png');
plots.MontageCmap(1, plotPath, img, names, false, limitVal);

img = {srgb, squeeze(scores(:, :, 1)), squeeze(scores(:, :, 2)), squeeze(scores(:, :, 3))};
names = {labelInfo.Diagnosis, strjoin({subName, '1'}, {' '}), strjoin({subName, '2'}, {' '}), strjoin({subName, '3'}, {' '})};
plotPath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), hsIm.ID, 'ca_overlay'), 'png');
plots.MontageWithLabel(2, plotPath, img, names, labelInfo.Labels, hsIm.FgMask);

fig = figure(3);
w = hsiUtility.GetWavelengths(311);
hold on
for i = 1:3
    v = explained(i);
    name = strcat('TransVector', num2str(i), '(', sprintf('%.2f%%', v), ')');
    plot(w, coeff(:,i), 'DisplayName', name ,'LineWidth', 2);
end
hold off 
xlabel('Wavelength (nm)');
ylabel('Coefficient (a.u.)');
legend('Location', 'northwest');
plotPath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), hsIm.ID, 'ca_vectors'), 'png');
plots.SavePlot(fig, plotPath);
end