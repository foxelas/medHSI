database = 'pslRaw32Augmented';
fullDatabase = 'pslRaw';

isAugmented = contains(lower(database), 'augmented');

config.SetSetting('Dataset', database);
baseDir = commonUtility.GetFilename('output', 'python-test', '');
folderList = dir(baseDir);
folderNames = {folderList([folderList.isdir]).name};
folderNames = folderNames(3:end);
n = 32;
 
 for i = 1:numel(folderNames)
     curDir = fullfile(baseDir, folderNames{i}, 'p_*.mat'); 
     resultImages = dir(curDir);
     names = {resultImages.name};
     samplesSplits = cellfun(@(x) strsplit(x, {'_'}) , names, 'un', 0); 
     samples = cellfun(@(x) x{2}, samplesSplits, 'un', 0);
     samples = unique(samples);
     
     for j = 1:numel(samples)
         config.SetSetting('Dataset', database);

         img = zeros(n, n, 311);
         pred = zeros(n, n);
         
         if isAugmented
            targetSamples = names(contains(names, samples{j}) & contains(names, '_0.'));
         else
            targetSamples = names(contains(names, samples{j}));
         end
         
         for k = 1:numel(targetSamples)
            id = strrep(targetSamples{k}, 'sample', '');
            id = strrep(id, '.mat', '');
            id = strrep(id, 'p_', '');

            [hsIm, labelInfo] = hsiUtility.LoadHsiAndLabel(id);
            pos = labelInfo.Comment; 
            ii = pos(1);
            jj = pos(2);
            img( (ii-1) * n  + 1 : ii * n, (jj-1) * n + 1 : jj * n, :) = hsIm.Value;
            load(fullfile(baseDir, folderNames{i}, targetSamples{k}), 'prediction');
            pred( (ii-1) * n  + 1 : ii * n, (jj-1) * n + 1 : jj * n) = imrotate(flip(prediction, 1), -90); %flip(imrotate(prediction, 90), 1);
         end
         
         config.SetSetting('Dataset', fullDatabase);
         [hsIm, labelInfo] = hsiUtility.LoadHsiAndLabel(strrep(samples{j}, 'sample', ''));
         baseImg = hsIm.GetDisplayImage();
         labelImg = rescale(labelInfo.Labels);
         
         [d1, d2] = size(labelImg); 
         predImg = zeros(d1, d2);
         predImg(1:size(pred,1), 1:size(pred,2) ) = pred;
         jacCoeff = jaccard(labelImg, round(predImg));

         rgbImg = zeros(d1, d2, 311);
         rgbImg(1:size(pred,1), 1:size(pred,2), :) = img;
         
         fig = figure(1); clf; 
         subplot(1, 3, 1);
         imshow(GetDisplayImageInternal(rgbImg));
         title('Input Image', 'FontSize', 12); 
%          axis square;
         
         subplot(1, 3, 2);
         imshow(labelImg);
         title('Ground Truth', 'FontSize', 12); 
%          axis square;

         subplot(1, 3, 3);
         imshow(predImg);
%          imagesc(predImg, [0, 1]);
%          c = colorbar();
         title( sprintf('Prediction %.2f%%', jacCoeff * 100), 'FontSize', 12); 
%          axis('off');
%          axis square;
         
         plotPath = fullfile(baseDir, folderNames{i}, strcat( samples{j} ,'.png'));
         plots.SavePlot(fig, plotPath);
         
         matPath = fullfile(baseDir, folderNames{i}, strcat( 'pred', strrep(samples{j}, 'sample', '') ,'.mat'));
         save(matPath, 'predImg');          
     end
 end