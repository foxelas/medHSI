function [] = Basics_GetLabelFromLabelMe(hsIm)

config.SetSetting('SaveFolder', '00-Labelme');
savedir = commonUtility.GetFilename('output', config.GetSetting('SaveFolder'), '');

if exist(fullfile(savedir, hsIm.ID, 'img.png')) > 0
    img = imread(fullfile(savedir, hsIm.ID, 'img.png'));
    lab = double(imread(fullfile(savedir, hsIm.ID, 'label.png')));

    % transFunc = @(x) flip(x, 1);
    % img = transFunc(img);
    % lab = transFunc(lab);
    % if str2double(hsIm.SampleID) <= 25
    %     img = imrotate(img, 90);
    %     lab = imrotate(lab, 90);
    % end

    figure(1);
    imshow(img);
    figure(2);
    imagesc(lab);

    saveLabelFolder = config.DirMake(config.GetSetting('DataDir'), config.GetSetting('LabelsFolderName'), hsIm.TissueType, strcat(hsIm.ID, '.png'));
    imwrite(lab, saveLabelFolder);
end

end