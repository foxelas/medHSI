folds = 2;
testTargets = {};
dataType = 'pixel';
dataset = config.GetSetting('Dataset');
[X, ~, ~] = trainUtility.SplitDataset(dataset, folds, testTargets, dataType);
Xscores = commonUtility.Cell2Mat({X.Values});

q = 4;

targetName = '181';
[hsIm, labelInfo] = hsiUtility.LoadHsiAndLabel(targetName);

[eigs{1}, ~, ~, explained{1}, ~] = dimredUtility.Apply(Xscores, 'PCA', q);
scores{1} = hsIm.GetMaskedPixels() * eigs{1};
scores{1} = RecoverOriginalDimensionsInternal(scores{1}, [size(hsIm.FgMask, 1), size(hsIm.FgMask, 2), 3], hsIm.FgMask);

[eigs{2}, scores{2}, ~, explained{2}, ~] = hsIm.Dimred('PCA', q);

pixelNum = 20;
superpixelLabels = cubseg(hsIm.Value, pixelNum);

targetLabel = 8;
maskSuper = superpixelLabels == targetLabel;
[eigs{3}, ~, ~, explained{3}, ~] = dimredUtility.Apply(hsIm.GetMaskedPixels(maskSuper), 'PCA', q);
[~, scores{3}, ~, ~, ~] = hsIm.Dimred('SuperPCA', q);


numEndmembers = 6;
endmembers = NfindrInternal(hsIm.Value, numEndmembers, hsIm.FgMask);
clusterLabels = DistanceScoresInternal(hsIm.Value, endmembers, @sam);
targetEndmember = 3;
maskCluster = clusterLabels == targetEndmember;
[eigs{4}, ~, ~, explained{4}, ~] = dimredUtility.Apply(hsIm.GetMaskedPixels(maskCluster), 'PCA', q);
scores{4} = SuperPCA(hsIm.Value, q, clusterLabels);

close all;

fig = figure(2);
srgb = hsIm.GetDisplayImage();
plotPath = config.DirMake(commonUtility.GetFilename('output', ...
    fullfile('Dimred-Pub', 'pca-each'), 'png'));
img = imshow(srgb);
img.AlphaData = hsIm.FgMask;
plots.SavePlot(fig, plotPath);
% plots.Overlay(fig, plotPath, srgb, ~hsIm.FgMask);

fig = figure(3);
plotPath = config.DirMake(commonUtility.GetFilename('output', ...
    fullfile('Dimred-Pub', 'pca-superpixel'), 'png'));
img = imshow(srgb);
alpha = maskSuper + 0.3;
alpha(~hsIm.FgMask) = 0;
img.AlphaData = alpha;
plots.SavePlot(fig, plotPath);
% plots.Overlay(fig, plotPath, srgb, ~maskSuper);

fig = figure(4);
plotPath = config.DirMake(commonUtility.GetFilename('output', ...
    fullfile('Dimred-Pub', 'pca-cluster'), 'png'));
img = imshow(srgb);
alpha = maskCluster + 0.3;
alpha(~hsIm.FgMask) = 0;
img.AlphaData = alpha;
plots.SavePlot(fig, plotPath);
% plots.Overlay(fig, plotPath, srgb, maskCluster);

fontSz = 15;
fig = figure(1);
names = {'Training across Dataset', 'Training per Sample', 'Training per Superpixel', 'Training per Cluster'};
w = hsiUtility.GetWavelengths(311);
for i = 1:4
    subplot(3, 2, i);
    curScore = eigs{i};
    hold on;
    for j = 1:3
        h(j) = plot(w, curScore(:, j), 'DisplayName', strcat('Transform Vector ', num2str(j)), 'LineWidth', 2);
    end
    hold off;
    xlabel('Wavelength (nm)', 'FontSize', fontSz);
    ylabel('Coefficient (a.u.)', 'FontSize', fontSz);
    xlim([400, 750]);
    ylim([-0.2, 0.2]);
    title(names{i}, 'FontSize', fontSz);
end
legend(h, 'Location', 'northwest', 'FontSize', fontSz);

subplot(3, 2, 5);

importDir = config.GetSetting('ImportDir');
pheomelaninFilename = 'pheomelanin_absroption.csv';
eumelaninFilename = 'eumelanin_absroption.csv';
hbFilename = 'hb_absorption_spectra_prahl.csv';
eumelaninData = delimread(fullfile(importDir, eumelaninFilename), ',', 'num');
eumelaninData = eumelaninData.num;
hbData = delimread(fullfile(importDir, hbFilename), ',', 'num');
hbData = hbData.num;
pheomelaninData = delimread(fullfile(importDir, pheomelaninFilename), ',', 'num');
pheomelaninData = pheomelaninData.num;

eumelaninLambda = eumelaninData(:, 1);
% extCoeffEumelanin1 = eumelaninData(:, 2);
extCoeffEumelanin2 = eumelaninData(:, 3);

pheomelaninLambda = pheomelaninData(:, 1);
% extCoeffPheomelanin1 = pheomelaninData(:, 2);
extCoeffPheomelanin2 = pheomelaninData(:, 3);

% hbAmount = 150; %   A typical value of x for whole blood is x=150 g Hb/liter.
% convertHbfun = @(x) 2.303 * hbAmount * x / 64500;
hbLambda = hbData(:, 1);
extCoeffHbO = hbData(:, 2);
extCoeffHbR = hbData(:, 3);
% absCoeffHbO = convertHbfun(extCoeffHbO);
% absCoeffHbR = convertHbfun(extCoeffHbR);

% (moles/liter) = M

colors = hsv(5);
hold on;
%plot(eumelaninLambda, extCoeffEumelanin1, 'DisplayName', 'Eumelanin1', 'LineWidth', 2); %cm-1 / (mg/ml)
plot(eumelaninLambda, extCoeffEumelanin2, 'DisplayName', 'Eumelanin', 'LineWidth', 2, 'Color', colors(2, :)); %cm-1 / (moles/liter)
plot(pheomelaninLambda, extCoeffPheomelanin2, 'DisplayName', 'Pheomelanin', 'LineWidth', 2, 'Color', colors(3, :)); %cm-1 / (moles/liter)
plot(hbLambda, extCoeffHbR, 'DisplayName', 'Hb', 'LineWidth', 2, 'Color', colors(4, :)); %cm-1/M
plot(hbLambda, extCoeffHbO, 'DisplayName', 'HbO_2', 'LineWidth', 2, 'Color', colors(5, :)); %cm-1/M
hold off
xlim([400, 750]);
xlabel('Wavelength (nm)', 'FontSize', fontSz);
ylabel('Absorption (cm^{-1}/ M)', 'FontSize', fontSz);
l = legend('Location', 'northeast', 'FontSize', fontSz);
title('Chromophore Absorption', 'FontSize', fontSz);
set(gca, 'yscale', 'log');


fig.WindowState = 'maximized';
plotPath = config.DirMake(commonUtility.GetFilename('output', ...
    fullfile('Dimred-Pub', 'eigTest'), 'png'));
plots.SavePlot(fig, plotPath);


fig = figure(6);
fontSz = 15;
fig = figure(1);
names = {'Training across Dataset', 'Training per Sample', 'Training per Superpixel', 'Training per Cluster'};
w = hsiUtility.GetWavelengths(311);
for i = 1:4
    ax = subplot(2, 2, i);
    curScore = scores{i};
    h = imagesc(ax, rescale(curScore(:, :, 3)), 'AlphaData', hsIm.FgMask);
    c = colorbar;
    colormap('winter');
    title(names{i}, 'FontSize', fontSz);
    ax.XTick = [];
    ax.YTick = [];
end
plotPath = config.DirMake(commonUtility.GetFilename('output', ...
    fullfile('Dimred-Pub', 'eig1'), 'png'));
plots.SavePlot(fig, plotPath);