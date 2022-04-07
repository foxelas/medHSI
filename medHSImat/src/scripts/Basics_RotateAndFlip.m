function [] = Basics_RotateAndFlip(hsIm, labelInfo, isInvert)

if nargin < 3
    isInvert = false;
end
config.SetSetting('SaveFolder', '00-Snapshots-Rotated');
savedir = commonUtility.GetFilename('output', config.GetSetting('SaveFolder'), '');
if ~isInvert
    transFunc = @(x) flip(x, 1);
    img = transFunc(hsIm.Value);
    if str2double(hsIm.SampleID) <= 25
        img = imrotate(img, 90);
    end
    hsIm.Value = img;


    plots.Show(1, fullfile(savedir, hsIm.ID), hsIm.GetDisplayImage());
    pause(0.5);
else

    img = imread(fullfile(savedir, hsIm.ID, 'img.png'));
    lab = double(imread(fullfile(savedir, hsIm.ID, 'label.png')));

    transFunc = @(x) flip(x, 1);
    img = transFunc(img);
    lab = transFunc(lab);
    if str2double(hsIm.SampleID) <= 25
        img = imrotate(img, 90);
        lab = imrotate(lab, 90);
    end

    figure(1);
    imshow(img);
    figure(2);
    imagesc(lab);

    saveLabelFolder = fullfile(config.GetSetting('DataDir'), config.GetSetting('LabelsFolderName'), hsIm.TissueType, strcat(hsIm.ID, '.png'));
    imwrite(lab, saveLabelFolder);

    pause(0.5);
end

end