function [] = Basics_RotateAndFlip(hsIm, labelInfo)
    transFunc = @(x) flip(x, 1);
    img = transFunc(hsIm.Value);
    img = imrotate(img, 90);
    hsIm.Value = img;
    
    config.SetSetting('saveFolder', '00-Snapshots-Rotated');
    savedir = commonUtility.GetFilename('output', fullfile(config.GetSetting('saveFolder'), config.GetSetting('fileName')), '');
    plots.Show(1, fullfile(savedir, hsIm.SampleID ), hsIm.GetDisplayImage());   
    pause(0.5);
end