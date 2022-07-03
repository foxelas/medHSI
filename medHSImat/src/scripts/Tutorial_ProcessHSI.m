close all;

%% Application on an image
targetID = '150';
config.SetSetting('SaveFolder', 'Test');
config.SetSetting('FileName', targetID);
savedir = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), config.GetSetting('FileName')), '');

%% Load the preprocessed data and label info
[spectralData, labelInfo] = hsiUtility.LoadHsiAndLabel(targetID);

%% Show sRGB imageg
figure(1);
srgb = spectralData.GetDisplayImage();
imshow(srgb); title('srgb')

%% Get the wavelengths
w = hsiUtility.GetWavelengths(311);

%% Apply a function on the hsi values
%e.g. Crop only a slice of the blue spectral range
transformFun = @(x) x(:, :, 30:50);
resultObj = hsIm.ApplyFucntion(tranformFun);

%% Apply Denoising
denoised = spectralData.Denoise('smoothen');
% See the denoised image compared to the original
plotPath = fullfile(savedir, 'denoise_pair');
figure(2);
montage({spectralData.GetDisplayImage(), denoised.GetDisplayImage()});
plots.SavePlot(2, plotPath);

% See the influence of denoising on the endmembers
numEndmembers = 8;
endmembersBefore = spectralData.FindPurePixels(numEndmembers, 'Nfindr');
endmembersAfter = denoised.FindPurePixels(numEndmembers, 'Nfindr');

figure(3);
subplot(2, 1, 1);
plot(w, endmembersBefore);
xlabel('Band Number')
ylabel('Data Value')
legend('Location', 'Bestoutside');
title('Endmembers (Before)');
xlim([420, 730]);

subplot(2, 1, 2);
plot(w, endmembersAfter);
xlabel('Band Number')
ylabel('Data Value')
legend('Location', 'Bestoutside');
title('Endmembers (After)');
xlim([420, 730]);

plotPath = fullfile(savedir, 'endmembers_comparison');
plots.SavePlot(3, plotPath);

%% Apply Dimension Reduction
