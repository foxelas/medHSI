load('D:\elena\mspi\matfiles\hsi\pslRaw\LeonReferences\LeonReferences.mat', 'references'); 

w = hsiUtility.GetWavelengths(311); 

figure(1);
tiledlayout(2,3);
for i = 1:6
    nexttile;
    plot(w, references(i).Signature, 'DisplayName', references(i).Type, 'LineWidth', 2);
  	if (references(i).Label)
        legend('Location', 'northwest', 'FontSize', 15);
        title(references(i).Diagnosis);
    else
        title('Non-neoplastic tissue');
    end
    xlabel('Wavelengths (nm)','FontSize', 15);
    ylabel('Reflectance (a.u.)','FontSize', 15);
end

set(gcf, 'Position', get(0, 'Screensize'));
filePath = 'D:\elena\mspi\output\common\';
plots.SavePlot(1, strcat(filePath, 'reference-sigs.png'));

load('D:\elena\mspi\matfiles\hsi\pslRaw\EndMembers\endmembers-8.mat')
figure(2);
tiledlayout(2,4);
for i = 1:8
    nexttile;
    plot(w, endmembers(:,i), 'DisplayName', strcat('Endmember', num2str(i)), 'LineWidth', 2);
    title(strcat('Endmember ', num2str(i)))
    xlabel('Wavelengths (nm)','FontSize', 15);
    ylabel('Reflectance (a.u.)','FontSize', 15);
end

set(gcf, 'Position', get(0, 'Screensize'));
filePath = 'D:\elena\mspi\output\common\';
plots.SavePlot(2, strcat(filePath, 'endmembers-sigs.png'));
