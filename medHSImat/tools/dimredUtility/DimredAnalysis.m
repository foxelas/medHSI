% ======================================================================
%> @brief Analysis reduces the dimensions of the hyperspectral image and produces evidence graphs.
%>
%> Currently available methods:
%> PCA, SuperPCA, MSuperPCA, ClusterPCA, MClusterPCA
%> ICA (FastICA), RICA, SuperRICA,
%> LDA, QDA, MSelect.
%> Methods autoencoder and RFI are available only for pre-trained models.
%>
%> Additionally, for pre-trained parameters RFI and Autoencoder are available.
%> For an unknown method, the input data is returned.
%>
%> @b Usage
%>
%> @code
%> q = 10;
%> [scores] = dimredUtility.Analysis(hsIm, labelInfo, 'pca', q);
%> @endcode
%>
%> @param hsIm [hsi] | An instance of the hsi class
%> @param labelInfo [hsiInfo] | An instance of the hsiInfo class
%> @param method [string] | The method for dimension reduction
%> @param q [int] | The number of components to be retained
%> @param fgMask [numerical array] | A 2D logical array marking pixels to be used in PCA calculation
%> @param labelMask [numerical array] | A 2D logical array marking pixels to be used in PCA calculation
%> @param varargin [cell array] | Optional additional arguments for methods that require them
%>
%> @retval scores [numeric array] | The transformed values
% ======================================================================
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
w = hsiUtility.GetWavelengths(size(hsIm.Value, 3));
hold on
for i = 1:3
    v = explained(i);
    name = strcat('TransVector', num2str(i), '(', sprintf('%.2f%%', v), ')');
    plot(w, coeff(:, i), 'DisplayName', name, 'LineWidth', 2);
end
hold off
xlabel('Wavelength (nm)');
ylabel('Coefficient (a.u.)');
legend('Location', 'northwest');
plotPath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), hsIm.ID, 'ca_vectors'), 'png');
plots.SavePlot(fig, plotPath);
end