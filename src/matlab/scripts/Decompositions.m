close all;

%% Read data
hasRead = false;
if hasRead
    load('D:\elena\mspi\matfiles\hsi\calibTriplets\94_white.mat')
    load('D:\elena\mspi\matfiles\hsi\calibTriplets\94_black.mat')
    load('D:\elena\mspi\matfiles\hsi\calibTriplets\94_target.mat')
    raw1 = spectralData;
    norm1 = NormalizeImage(spectralData, fullReflectanceByPixel, blackReflectance);

    load('D:\elena\mspi\matfiles\hsi\calibTriplets\67_white.mat')
    load('D:\elena\mspi\matfiles\hsi\calibTriplets\67_black.mat')
    load('D:\elena\mspi\matfiles\hsi\calibTriplets\67_target.mat')
    raw2 = spectralData;
    norm2 = NormalizeImage(spectralData, fullReflectanceByPixel, blackReflectance);

    allowDrawMask = false;
    if allowDrawMask
        [mask2, maskedPixels2] = GetMaskFromFigure(norm2);
        save('norm2_goodPixels.mat', 'norm2', 'mask2', 'maskedPixels2');

        [mask1, maskedPixels1] = GetMaskFromFigure(norm1);
        save('norm1_goodPixels.mat', 'norm1', 'mask1', 'maskedPixels1', '-v7.3');
    else
        load('D:\elena\Google Drive\titech\research\experiments\output\hsi\python\pca\exp4_norm_cropped_sample_only\norm1_goodPixels.mat');
        load('D:\elena\Google Drive\titech\research\experiments\output\hsi\python\pca\exp4_norm_cropped_sample_only\norm2_goodPixels.mat');
        maskedPixels2 = GetPixelsFromMask(norm2, mask2);
        maskedPixels1 = GetPixelsFromMask(norm1, mask1);
    end

    Xraw401 = [reshape(raw1, [size(raw1, 1) * size(raw1, 2), size(raw1, 3)]); reshape(raw2, [size(raw2, 1) * size(raw2, 2), size(raw2, 3)])];
    Xmask401 = [maskedPixels1; maskedPixels2];
    w = [420:730];
    Xraw = Xraw401(:, w-380+1);
    Xmask = Xmask401(:, w-380+1);
end

%% Select methods, dataset
method = 'rica'; %'pca', 'rica'
X = Xmask; %Xmask  Xraw

curDir = 'python\ica'; %'python\ica' 'python\pca'
folder = 'exp4_norm_cropped_sample_only'; %'exp4_norm_cropped_sample_only'; %'exp3_norm_cropped'; %'exp1_raw_full';
saveto = fullfile(GetSetting('saveDir'), curDir, folder);
DirMake(saveto);
SetSetting('saveDir', saveto);

q = 10;
[coeff, scores, latent, explained, objective] = Dimred(X, method, q);
redHsis = ReconstructDimred(scores, imgSizes, masks);

%% Plot images for components
if stcmp(method, 'pca')
    dimredResult = {coeff, scores, latent, explained};
elseif strcmp(method, 'rica')
    dimredResult = {coeff, scores, objective};
else
    error('Unsupported dimred method');
end
PlotDimred(method, dimredResult, w, redHsis);

%% Prepare 3-top components
WriteTopComponents(redHsis, method);

%% Reconstruct reduced data to original dimension
hasMask = size(X, 1) ~= (size(norm1, 1) * size(norm1, 2) + size(norm2, 1) * size(norm2, 2));
if ~hasMask
    splitIndex = size(norm1, 1) * size(norm1, 2);
else
    splitIndex = size(maskedPixels1, 1);
end
redHsi1 = scores(1:splitIndex, :);
redHsi2 = scores((splitIndex + 1):end, :);

if hasMask
    [redHsi1] = RecoverReducedHsi(redHsi1, size(norm1), mask1);
    [redHsi2] = RecoverReducedHsi(redHsi2, size(norm2), mask2);
else
    [redHsi1] = RecoverReducedHsi(redHsi1, size(norm1));
    [redHsi2] = RecoverReducedHsi(redHsi2, size(norm2));
end

%% Plot components
SetSetting('plotName', fullfile(saveto, 'img1_pcs'));
Plots(4, @PlotSubimageMontage, redHsi1, 'Tissue1', 6);
SetSetting('plotName', fullfile(saveto, 'img2_pcs'));
Plots(5, @PlotSubimageMontage, redHsi2, 'Tissue2', 6);

name = strcat(subimageName, '1');
figure(6);
imagesc(redHsi1(:, :, 1));
title(name);
colorbar
SetSetting('plotName', fullfile(saveto, strrep(lower(name), '_', '_')));
SavePlot(6);
name = strcat(subimageName, '2');
figure(7);
imagesc(redHsi1(:, :, 2));
title(name);
colorbar
SetSetting('plotName', fullfile(saveto, strrep(lower(name), '_', '_')));
SavePlot(7);
name = strcat(subimageName, '3');
figure(8);
imagesc(redHsi1(:, :, 3));
title(name);
colorbar
SetSetting('plotName', fullfile(saveto, strrep(lower(name), '_', '_')));
SavePlot(8);

%% Prepare 3-top components
dbDir = DirMake(GetSetting('saveDir'), 'database', 'test_tissue', method);
img1 = redHsi1(:, :, 1:3);
img2 = redHsi2(:, :, 1:3);

figure(9);
imshow(img1);
imwrite(img1, DirMake(dbDir, 'tissue1.jpg'), 'jpg');
figure(10);
imshow(img2);
imwrite(img2, DirMake(dbDir, 'tissue2.jpg'), 'jpg');

img = img1;
save(DirMake(dbDir, 'tissue1.mat'), 'img');
img = img2;
save(DirMake(dbDir, 'tissue2.mat'), 'img');
