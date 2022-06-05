
dirs = {'D:\elena\mspi\output\pslRaw32Augmented\python-test\validation\2022-06-02_sm_resnet\0_performance.mat'; 
    'D:\elena\mspi\output\pslRaw32Augmented\python-test\validation\2022-06-04_cnn3d_optimized\0_performance.mat';
    'D:\elena\mspi\output\pslRaw32Augmented\python-test\validation\2022-06-05_sm_resnet_pretrained_optimized\0_performance.mat'};

names = {'Resnet', 'Pretrained Resnet', '3D CNN'};
close all;
figure(1);

folds = 13;
hasSens = true;
if hasSens 
    fprintf('Accuracy & Sensitivity & Specificity & JC & AUC \n');
else
    fprintf('Accuracy & Precision & Recall & JC & AUC \n');
end

hold on
for i = 1:numel(dirs)
    load(dirs{i})
    
    v = cell2mat(testEval);

    iouVals1 = [v.val_iou_score] * 100;
    xVals1 = 1:folds;
    plot(xVals1, iouVals1, 'DisplayName', names{i}, 'LineWidth', 2);
    
    auc = mean(auc_val_);
    
    sensitivities = [v.val_true_positives] ./ ([v.val_true_positives] + [v.val_false_negatives]);
    specificities = [v.val_true_negatives] ./ ([v.val_true_negatives] + [v.val_false_positives]);
    
    if ~hasSens
        fprintf('%s & %.2f (%.2f) & %.2f (%.2f) & %.2f (%.2f) & %.2f (%.2f) & %.3f\n', ...
            names{i}, mean([v.val_accuracy]) * 100, std([v.val_accuracy]) * 100 / folds, mean(sensitivities) * 100, std(sensitivities) * 100 / folds, ...
            mean(specificities) * 100, std(specificities) * 100 / folds, mean([v.val_iou_score]) * 100, std([v.val_iou_score]) * 100 / folds, auc);
    else
        fprintf('%s & %.2f (%.2f) & %.2f (%.2f) & %.2f (%.2f) & %.2f (%.2f) & %.3f\n', ...
            names{i}, mean([v.val_accuracy]) * 100, std([v.val_accuracy]) * 100 / folds, mean([v.val_precision]) * 100, std([v.val_precision]) * 100 / folds, ...
            mean([v.val_recall]) * 100, std([v.val_recall]) * 100 / folds, mean([v.val_iou_score]) * 100, std([v.val_iou_score]) * 100 / folds, auc);
    end
    
    result = struct('Accuracy', mean([v.val_accuracy]) * 100, 'Precision', mean([v.val_precision]) * 100, ...
        'Recall',  mean([v.val_recall]) * 100, 'JC', mean([v.val_iou_score]) * 100, ...
        'AccSEM', std([v.val_accuracy]), 'PreSEM', std([v.val_precision]) * 100 / 13,'RecSEM',  std([v.val_recall]) * 100 / 13,'JCSEM', std([v.val_iou_score]) * 100 / 13);

end 
hold off

legend('FontSize', 15);
xlabel('Patient Test Fold', 'FontSize', 15);
ylabel('Jaccard Coefficient', 'FontSize', 15);
xlim([1,13]);
xticks(1:13);
ylim([0,100]);
yticks(0:10:100);


