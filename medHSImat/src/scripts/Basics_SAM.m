function [] = Basics_SAM()

rng(1); % For reproducibility

config.SetSetting('dataset', 'pslTest'); 
experiment = strcat('SAM segmentation-BCC');
config.SetSetting('experiment', experiment);
config.SetSetting('saveFolder', experiment);

fprintf('Running for dataset %s\n', config.GetSetting('dataset'));
%%%%%%%%%%%%%%%%%%%%%% Fix %%%%%%%%%%%%%%%%%%%%%%%%%

%% Read h5 data
folds = 5;
testTargets = {}; % {'166'};
dataType = 'hsi';
hasLabels = true;

[X, y, ~, ~, ~, ~, ~] = trainUtility.SplitTrainTest(config.GetSetting('dataset'), testTargets, dataType, hasLabels, folds);

Nim = numel(X);
for i = 1:Nim
    hsIm = X{i};
    [scoreImg, labelImg, argminImg] = hsi.SAMscore(hsIm);
    
    figure(1);clf;
    % subplot 3
    subplot(2,2,3);
    imshow(double(labelImg));
    hold on;
    h(1) = scatter([],[], 1, 'k', 'filled', 'DisplayName', 'Benign');
    h(2) = scatter([],[], 1, 'k', 'o', 'DisplayName', 'Malignant');
    hold off;
    legend(h, 'Location', 'northeast');
    title('SAM-based segmentation');
    
    % subplot 1
    subplot(2,2,1);
    imagesc(scoreImg, [0 1]);
    c = colorbar(gca, 'Ticks',[0, 0.2, 0.4, 0.6, 0.8, 1],...
         'TickLabels',{'Min', '0.2', '0.4', '0.6', '0.8', 'Max'});
    title('Minimum SAM value');
    axis equal
    axis off;

    % subplot 2
    subplot(2,2,2);
    imagesc(argminImg);
    un_X =[0:4]; % unique(argminImg);
    colormap(gca, jet(length(un_X)));
    b = colorbar(gca);
    set(b,'ytick',un_X);
    colorbar('Ticks',[0, 1, 2, 3, 4],...
         'TickLabels',{'0', '1', '2', '3', '4'});
    title('Argmin SAM value');
    axis equal
    axis off;

    % subplot 4
    subplot(2,2,4);
    [ssimval,ssimmap] = ssim(labelImg, y{i}.Labels);
    imshowpair(labelImg, y{i}.Labels, 'Scaling','joint');
    title(sprintf('SSIM: %.5f', ssimval));
    
    config.SetSetting('plotName', commonUtility.GetFilename('output', fullfile(config.GetSetting('saveFolder'), strcat('sam_', hsIm.ID )), 'jpg'));
    plots.SavePlot(1);
end


end
