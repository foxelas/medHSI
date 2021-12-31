function [Inorm_mask, srgb] = GetAverageSpectraInROI(sampleId)
load(strcat('D:\elena\mspi\matfiles\hsi\pslTriplets\', num2str(sampleId),'_target.mat'), 'spectralData');
Iin = spectralData;
load(strcat('D:\elena\mspi\matfiles\hsi\pslTriplets\', num2str(sampleId),'_black.mat'), 'blackReflectance');
Iblack = blackReflectance;
load(strcat('D:\elena\mspi\matfiles\hsi\pslTriplets\', num2str(sampleId),'_white.mat'), 'fullReflectanceByPixel');
Iwhite = fullReflectanceByPixel;

srgb = GetDisplayImageInternal(Iin);
denom = Iwhite - Iblack;
% denom(denom <= 0) = 0.000000001;
normI = (Iin - Iblack) ./ denom;

figure(1);
clf;
[mask, Iin_mask] = GetMaskFromFigureInternal(Iin);
Iblack_mask = GetPixelsFromMaskInternal(Iblack, mask);
Iwhite_mask = GetPixelsFromMaskInternal(Iwhite, mask);
Inorm_mask = GetPixelsFromMaskInternal(normI, mask);

% close all;
% figure(1);
% clf;
% hold on;
% plot(380:780, mean(reshape(Iwhite_mask, [size(Iwhite_mask, 1), size(Iwhite_mask, 2)])), 'DisplayName', 'Average White');
% plot(380:780, mean(reshape(Iblack_mask, [size(Iblack_mask, 1) , size(Iblack_mask, 2)])), 'DisplayName', 'Average Black');
% plot(380:780, mean(reshape(Iin_mask, [size(Iin_mask, 1) , size(Iin_mask, 2)])), 'DisplayName', 'Average Tissue');
% 
% plot(380:780, min(reshape(Iwhite_mask, [size(Iwhite_mask, 1), size(Iwhite_mask, 2)])), 'DisplayName', 'Min White');
% plot(380:780, min(reshape(Iblack_mask, [size(Iblack_mask, 1) , size(Iblack_mask, 2)])), 'DisplayName', 'Min Black');
% plot(380:780, min(reshape(Iin_mask, [size(Iin_mask, 1) , size(Iin_mask, 2)])), 'DisplayName', 'Min Tissue');
% 
% hold off; legend
% min(Iwhite_mask(:)-Iblack_mask(:))
% 
% figure(2);
% hold on 
% for i = 1:size(Inorm_mask, 1)
%     plot(380:780, Inorm_mask(i,:), 'g');
% end
% h = plot(380:780, mean(reshape(Inorm_mask, [size(Inorm_mask, 1), size(Inorm_mask, 2)])), 'DisplayName', 'Average Normalized', 'LineWidth', 3);
% hold off
% ylim([0,1]);
% xlim([420, 750]);
% legend(h)

end

