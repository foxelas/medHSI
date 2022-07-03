load('D:\elena\mspi\output\pslRaw32Augmented\python-test\optimization\cnn3d\0_performance.mat');
v = cell2mat(testEval);

% Adam, BCE, no decay
decVals = cell2mat(cellfun(@(x) x == 0, {v.decay}, 'un', 0));
idx = strcmpi({v.optimizer}, 'Adam') & decVals & strcmpi({v.lossFunction}, 'BCE');
iouVals1 = [v(idx).val_iou_score];
xVals1 = [v(idx).learningRate];

% RMSProp, BCE, no decay
decVals = cell2mat(cellfun(@(x) x == 0, {v.decay}, 'un', 0));
idx = strcmpi({v.optimizer}, 'RMSProp') & decVals & strcmpi({v.lossFunction}, 'BCE');
iouVals2 = [v(idx).val_iou_score];
xVals2 = [v(idx).learningRate];

% Adam, BCE+JC, no decay
decVals = cell2mat(cellfun(@(x) x == 0, {v.decay}, 'un', 0));
idx = strcmpi({v.optimizer}, 'Adam') & decVals & ~strcmpi({v.lossFunction}, 'BCE');
iouVals3 = [v(idx).val_iou_score];
xVals3 = [v(idx).learningRate];

% RMSProp, BCE+JC, no decay
decVals = cell2mat(cellfun(@(x) x == 0, {v.decay}, 'un', 0));
idx = strcmpi({v.optimizer}, 'RMSProp') & decVals & ~strcmpi({v.lossFunction}, 'BCE');
iouVals4 = [v(idx).val_iou_score];
xVals4 = [v(idx).learningRate];

figure(1);
hold on;
plot(xVals1, iouVals1, 'DisplayName', 'Adam, BCE, no decay', 'LineWidth', 2);
plot(xVals2, iouVals2, 'DisplayName', 'RMSProp, BCE, no decay', 'LineWidth', 2);
plot(xVals3, iouVals3, 'DisplayName', 'Adam, BCE+JC, no decay', 'LineWidth', 2);
plot(xVals4, iouVals4, 'DisplayName', 'RMSProp, BCE+JC, no decay', 'LineWidth', 2);
hold off;

ax = gca;
ax.XAxis.Exponent = 0;

xlabel('Learning Rate');
ylabel('IOU')
legend('FontSize', 12);

%%% Decay

% RMSProp, BCE+JC, no decay
decVals = cell2mat(cellfun(@(x) x == 0, {v.decay}, 'un', 0));
idx = strcmpi({v.optimizer}, 'RMSProp') & decVals & ~strcmpi({v.lossFunction}, 'BCE');
iouVals1 = [v(idx).val_iou_score];
xVals1 = [v(idx).learningRate];

% RMSProp, BCE+JC, decay 1.0e-05
decVals = cell2mat(cellfun(@(x) x == 1.0e-05, {v.decay}, 'un', 0));
idx = strcmpi({v.optimizer}, 'RMSProp') & decVals & ~strcmpi({v.lossFunction}, 'BCE');
iouVals2 = [v(idx).val_iou_score];
xVals2 = [v(idx).learningRate];

% RMSProp, BCE+JC, decay 1.0e-06
decVals = cell2mat(cellfun(@(x) x == 1.0e-06, {v.decay}, 'un', 0));
idx = strcmpi({v.optimizer}, 'RMSProp') & decVals & ~strcmpi({v.lossFunction}, 'BCE');
iouVals3 = [v(idx).val_iou_score];
xVals3 = [v(idx).learningRate];


figure(2);
hold on;
plot(xVals1, iouVals1, 'DisplayName', 'RMSProp, BCE+JC, no decay', 'LineWidth', 2);
plot(xVals2, iouVals2, 'DisplayName', 'RMSProp, BCE+JC, decay 1.e-5', 'LineWidth', 2);
plot(xVals3, iouVals3, 'DisplayName', 'RMSProp, BCE+JC, decay 1.e-6', 'LineWidth', 2);
hold off;

ax = gca;
ax.XAxis.Exponent = 0;

xlabel('Learning Rate');
ylabel('IOU')
legend('FontSize', 12);

figure(3);

load('D:\elena\mspi\output\pslRaw32Augmented\python-test\test-wavelength\test3\0_performance.mat');
v = cell2mat(testEval);
y = [v.val_iou_score] * 100;
yy = [v.val_precision] * 100;
x = [5, 10, 20, 30];
plot(x, y, 'LineWidth', 2);
ylim([50, 100]);
ylabel('Jaccard Coefficient (%)', 'FontSize', 15);
xlabel('Kernel Size in Spectral Dimension', 'FontSize', 15);
yyaxis right;
plot(x, yy, 'LineWidth', 2);
ylim([50, 100]);
ylabel('Precision (%)', 'FontSize', 15);


load('D:\elena\mspi\output\split3\segmentation\trainData.mat')
v = cellfun(@(x) sum(x(:)), {trainData.Masks}, 'un', 0);
z = cellfun(@(x) sum(x(:)), {trainData.ImageLabels}, 'un', 0);
load('D:\elena\mspi\output\split3\segmentation\testData.mat')
testData = testData(1:end-3);
testData(3) = [];
v2 = cellfun(@(x) sum(x(:)), {testData.Masks}, 'un', 0);
z2 = cellfun(@(x) sum(x(:)), {testData.ImageLabels}, 'un', 0);
v11 = sum(cell2mat(v));
z11 = sum(cell2mat(z));
v22 = sum(cell2mat(v2));
z22 = sum(cell2mat(z2));
z11 / v11 * 100
z22 / v22 * 100