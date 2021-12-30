
sampleIds = [150, 163, 175, 181]; %157, 160,
names = {'mucinous carcinoma', 'basal cell carcinoma', 'Bowen’s disease', 'basal cell carcinoma'};
divBy = 0.0015;

figure(1);
clf;
 for j = 1:4
     sampleId = sampleIds(j);
     [spectrumCurves, rgb] = prepareData(sampleId);
      x = hsiUtility.GetWavelengths(311);

     subplot(4, 2, (j-1)*2 + 1);
     hold on
     for i=1:10:size(spectrumCurves, 1)
         plot(x, spectrumCurves(i,:) ./divBy, 'g');
     end
     avg = mean(spectrumCurves);
     h = plot(x, avg ./divBy, 'b*', 'DisplayName', 'Mean', 'LineWidth', 3); 
     hold off
     ylim([0,1]);
     xlabel('Wavelength (nm)');
     ylabel('Normalized Spectrum (a.u.)');
     legend(h);

     subplot(4, 2, j*2);
     imshow(rgb);
     title(names{j});
 end
 
 config.SetSetting('plotName', fullfile(config.DirMake(config.GetSetting('saveDir'), 'T20211230-review'), 'spectra-example.jpg'));
 plots.SavePlot(1);
 
 function [spectrumCurves, rgb] = prepareData(sampleId)
 load(strcat('D:\elena\mspi\matfiles\hsi\pslNormalized\', num2str(sampleId),'_byPixel.mat'));
  
 hsiIm = hsi;
 hsiIm.Value = spectralData;
 [rgb] = hsiIm.GetDisplayImage();
 [fgMask] = GetFgMask(hsiIm);
 [spectrumCurves] = GetPixelsFromMask(hsiIm, fgMask);
 end
 
 