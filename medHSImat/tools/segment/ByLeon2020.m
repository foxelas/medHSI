% ======================================================================
%> @brief ByLeon2020 implements segmentation according to Leon (2020).
%>
%> For details check Leon, R., Martinez-Vega, B., Fabelo, H., Ortega, S., Melian, V., Castaño, I., Carretero, G., Almeida, P., Garcia, A., Quevedo, E., Hernandez, J. A., Clavo, B., & M. Callico, G. (2020). Non-Invasive Skin Cancer Diagnosis Using Hyperspectral Imaging for In-Situ Clinical Support. Journal of Clinical Medicine, 9(6), 1662. https://doi.org/10.3390/jcm9061662
%>
%> @b Usage
%>
%> @code
%> segopt = segopt.GetOptions('Leon2020');
%> labels = segment.Apply(hsIm, segopt);
%> @endcode
%>
%> @param hsIm [hsi] | An instance of the hsi class
%> @param segopt [struct] | The segmentation options
%>
%> @retval labels [numeric array] | The segmented labels
% ======================================================================
function [labels] = ByLeon2020(hsIm, segopt)
% ByLeon2020 implements segmentation according to Leon (2020).
%
% For details check Leon, R., Martinez-Vega, B., Fabelo, H., Ortega, S., Melian, V., Castaño, I., Carretero, G., Almeida, P., Garcia, A., Quevedo, E., Hernandez, J. A., Clavo, B., & M. Callico, G. (2020). Non-Invasive Skin Cancer Diagnosis Using Hyperspectral Imaging for In-Situ Clinical Support. Journal of Clinical Medicine, 9(6), 1662. https://doi.org/10.3390/jcm9061662
%
% @b Usage
%
% @code
% segopt = segopt.GetOptions('Leon2020');
% labels = segment.Apply(hsIm, segopt);
% @endcode
%
% @param hsIm [hsi] | An instance of the hsi class
% @param segopt [struct] | The segmentation options
%
% @retval labels [numeric array] | The segmented labels

k = segopt.MainClasses;
voting = segopt.VotingScheme;
mainSegFun = segopt.MainSegmentation;

refLibrary = hsiUtility.GetReferenceLibrary();
n = numel(refLibrary);

if options.HasInitialSegmentation
    kin = segopt.InitialClasses;
    initSegFun = segopt.InitialSegmentation;
    [labelsInit, centroids] = initSegFun(hsIm, kin);

    %% Segmenet first class as background with label -1

    %%
    unit = options.MainUnit;
    labels = ones(size(labelsInit)) * (-1);
    for i = 1:kin
        mask = labelsInit == i;
        colPixels = hsIm.GetPixelsFromMask(mask);

        if strcmpi(unit, 'pixel')

            %% Assign label by cluster pixels
            samVal = zeros(n, 1);
            for j = 1:n
                if strcmpi(voting, 'MinimumSum')
                    for k = 1:size(colPixels, 1)
                        samVal(j) = samVal(j) + sam(colPixels(k, :), refLibrary(j).Data);
                    end
                    idMin = samVal == min(samVal);
                    labelCentroid = refLibrary(idMin).Label;
                    labels(mask) = labelCentroid;
                else
                    error('Not supported.');
                end
            end

        elseif strcmpi(unit, 'centroid')

            %% Assign label by cluster centroid

            samVal = zeros(n, 1);
            for j = 1:n
                samVal(j) = sam(centroids(i, :), refLibrary(j).Data);
            end

            if strcmpi(voting, 'Minimum')
                idMin = samVal == min(samVal);
                labelCentroid = refLibrary(idMin).Label;
            else
                error('Not supported.');
            end
            labels(mask) = labelCentroid;
        else
            error('Not supported.');
        end
    end

else
    labels = mainSegFun(hsiIm, targetName, k);
end
end
