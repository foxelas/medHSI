load('D:\temp\uni\mspi\output\pslRaw\Dimred28-Apr-2022-rbf-100000-outlier0,05\cvpInfo.mat');

all = [trainData', testData']';
for i = 1:19
    value(i, :) = mean(all(i).Values.GetMaskedPixels(all(i).ImageLabels));
    names{i} = all(i).Labels.Diagnosis;
    label(i) = strcmpi(all(i).Labels.Type, 'Malignant');
end

unnames = unique(names);
for i = 1:length(unnames)
    ids = strcmpi(names, unnames{i});
    if sum(ids) > 1
        limValue(i, :) = mean(value(ids, :));
    else
        limValue(i, :) = value(ids, :);
    end
end


figure(1);
hold on
for i = 1:8
    plot(hsiUtility.GetWavelengths(311), limValue(i, :), 'DisplayName', unnames{i}, 'LineWidth', 2);
end
legend('FontSize', 15);
xlabel('Wavelength (nm)', 'FontSize', 15);
ylabel('Reflectance (a.u.)', 'FontSize', 15);
legend('FontSize', 15, 'Location', 'Eastoutside');


ids = strcmpi(unnames, 'Basal Cell Carcinoma');
i = 1;
references(i).Signature = limValue(ids, :);
references(i).Label = 1;
references(i).Diagnosis = 'Malignant';
references(i).Type = 'Basal Cell Carcinoma';

ids = strcmpi(unnames, 'Melanocytic Nevus');
i = 2;
references(i).Signature = limValue(ids, :);
references(i).Label = 1;
references(i).Diagnosis = 'Benign';
references(i).Type = 'Melanocytic Nevus';

ids = strcmpi(unnames, 'Malignant Melanoma');
i = 3;
references(i).Signature = limValue(ids, :);
references(i).Label = 1;
references(i).Diagnosis = 'Malignant';
references(i).Type = 'Malignant Melanoma';


j = 13; % Dermatofibroma
values = mean(all(j).Values.GetMaskedPixels(~all(j).ImageLabels & all(j).Values.FgMask));
% figure(3); imshow(~all(j).ImageLabels & all(j).Values.FgMask); pause(0.5);
i = 4;
references(i).Signature = values;
references(i).Label = 0;
references(i).Diagnosis = 'Healthy';
references(i).Type = 'Dermatofibroma';

j = 14; % Melanocytic Nevus
values = mean(all(j).Values.GetMaskedPixels(~all(j).ImageLabels & all(j).Values.FgMask));
% figure(4);imshow(~all(j).ImageLabels & all(j).Values.FgMask); pause(0.5);
i = 5;
references(i).Signature = values;
references(i).Label = 0;
references(i).Diagnosis = 'Healthy';
references(i).Type = 'Melanocytic Nevus';


j = 2; % Basal Cell Carcinoma
values = mean(all(j).Values.GetMaskedPixels(~all(j).ImageLabels & all(j).Values.FgMask));
% figure(5);imshow(~all(j).ImageLabels & all(j).Values.FgMask); pause(0.5);
i = 6;
references(i).Signature = values;
references(i).Label = 0;
references(i).Diagnosis = 'Healthy';
references(i).Type = 'Basal Cell Carcinoma';

figure(2);
for i = 1:numel(references)
    subplot(2, 3, i);
    plot(hsiUtility.GetWavelengths(311), references(i).Signature, 'DisplayName', references(i).Type, 'LineWidth', 2);
    xlabel('Wavelength (nm)', 'FontSize', 12);
    ylabel('Reflectance (a.u.)', 'FontSize', 12);
    title(references(i).Diagnosis);
    ylim([0, 1]);
    if ~strcmpi(references(i).Diagnosis, 'Healthy')
        legend('FontSize', 12, 'Location', 'northwest');
    end
end
