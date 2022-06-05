
dirs = {'D:\elena\mspi\output\pslRaw32Augmented\python-test\validation\2022-06-02_sm_resnet\0_performance.mat'; 
    'D:\elena\mspi\output\pslRaw32Augmented\python-test\validation\2022-06-04_cnn3d_optimized\0_performance.mat';
    'D:\elena\mspi\output\pslRaw32Augmented\python-test\validation\2022-06-05_sm_resnet_pretrained_optimized\0_performance.mat'};

names = {'Resnet', 'Pretrained Resnet', '3D CNN'};
figure(1);

fprintf('Accuracy & Precision & Recall & JC & AUC \n');

hold on
for i = 1:numel(dirs)
    load(dirs{i})
    
    v = cell2mat(testEval);

    iouVals1 = [v.val_iou_score];
    xVals1 = 1:13;
    plot(xVals1, iouVals1, 'DisplayName', names{i}, 'LineWidth', 2);
    
    auc = mean(auc_val_);
    
    folds = 13;
    fprintf('%s & %.2f (%.2f) & %.2f (%.2f) & %.2f (%.2f) & %.2f (%.2f) & %.3f\n', ...
        names{i}, mean([v.val_accuracy]) * 100, std([v.val_accuracy]) * 100 / 13, mean([v.val_precision]) * 100, std([v.val_precision]) * 100 / 13, ...
        mean([v.val_recall]) * 100, std([v.val_recall]) * 100 / 13, mean([v.val_iou_score]) * 100, std([v.val_iou_score]) * 100 / 13, auc);

    result = struct('Accuracy', mean([v.val_accuracy]) * 100, 'Precision', mean([v.val_precision]) * 100, ...
        'Recall',  mean([v.val_recall]) * 100, 'JC', mean([v.val_iou_score]) * 100, ...
        'AccSEM', std([v.val_accuracy]), 'PreSEM', std([v.val_precision]) * 100 / 13,'RecSEM',  std([v.val_recall]) * 100 / 13,'JCSEM', std([v.val_iou_score]) * 100 / 13);

end 
hold off

legend('FontSize', 15);
xlabel('Patient Test Fold', 'FontSize', 15);
ylabel('IOU', 'FontSize', 15);

