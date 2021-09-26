% Apply super pca 

SetSetting('isTest', false);
SetSetting('database', 'psl');
SetSetting('normalization', 'byPixel');
fileNum = 150;
SetSetting('fileName', num2str(fileNum));
hsi = ReadStoredHSI(fileNum, GetSetting('normalization'));
srgb = GetDisplayImage(hsi, 'rgb');
fgMask = ~(squeeze(srgb(:, :, 1)) == 0 & squeeze(srgb(:, :, 1)) == 0 & squeeze(srgb(:, :, 1)) == 0);

%% Settings 

num_Pixel = 20;
num_PC = 3;

%% super-pixels segmentation
labels = cubseg(hsi,num_Pixel);

%% SupePCA based DR
[dataDR] = SuperPCA(hsi,num_PC,labels);

%% Plots 
Plots(1, @PlotSuperpixels, srgb, labels);
PlotComponents(dataDR, 3, 2);
Plots(5, @PlotSuperpixels, srgb, labels, '', 'color', fgMask);


