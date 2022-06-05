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
