
sampleIds = [150, 163, 175, 181]; %157, 160,
names = {'mucinous carcinoma', 'basal cell carcinoma', 'Bowen’s disease', 'basal cell carcinoma'};
divBy = 1;

close all;
figure(2);
figure('units', 'normalized', 'outerposition', [0, 0, 1, 1]);

clf;
for j = 1:4
    sampleId = sampleIds(j);
    [spectrumCurves, rgb] = GetAverageSpectraInROI(sampleId);
    x = hsiUtility.GetWavelengths(size(spectrumCurves, 2));

    figure(2);
    subplot(4, 2, (j - 1)*2+1);
    hold on
    for i = 1:size(spectrumCurves, 1)
        plot(x, spectrumCurves(i, :)./divBy, 'g');
    end
    avg = mean(spectrumCurves);
    h = plot(x, avg./divBy, 'b*', 'DisplayName', 'Mean', 'LineWidth', 2);
    hold off
    ylim([0, 1]);
    xlim([420, 750]);
    xlabel('Wavelength (nm)');
    ylabel('Reflectance (a.u.)');
    legend(h, 'Location', 'northwest');

    subplot(4, 2, j*2);
    imshow(rgb);
    title(names{j});
end

config.SetSetting('plotName', fullfile(config.DirMake(config.GetSetting('saveDir'), 'T20211230-review'), 'spectra-example.jpg'));
plots.SavePlot(2);
