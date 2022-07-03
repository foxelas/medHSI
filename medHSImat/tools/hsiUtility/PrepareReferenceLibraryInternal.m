%======================================================================
%> @brief PrepareReferenceLibrary reads and prepares a library of spectral references.
%>
%> It can be used for various comparisons, including Spectral Angle
%> Mapper (SAM) calculation.
%> The result is saved in config::[MatDir]\\[Database]\\[ReferenceLibraryName]\\[ReferenceLibraryName].mat.
%> After creating it can be loaded with @c hsiUtility.GetReferenceLibrary.
%>
%> @b Usage
%>
%> @code
%>     referenceIDs = {153, 166};
%>     refLib = hsiUtility.PrepareReferenceLibrary(referenceIDs);
%> @endcode
%>
%> @param refIDs [cell array] | A cell array of strings that
%> includes all target reference IDs for samples to be included in the library.
%>
%> @retval refLib [struct] | A struct that contains the reference
%> library. The struct has fields 'Data', 'Label' (Malignant (1) or
%> Benign (0)) and 'Disease'.
%>
%======================================================================
function [refLib] = PrepareReferenceLibraryInternal(refIDs)

refLib = struct('Data', [], 'Label', [], 'Diagnosis', []);
k = 0;
for i = 1:length(refIDs)
    targetName = num2str(refIDs{i});
    [hsiIm, labelInfo] = hsiUtility.LoadHsiAndLabel(targetName);
    if ~hsi.IsHsi(hsiIm)
        error('Needs preprocessed input. Change [normalization] in config.');
    end
    labelImg = labelInfo.Labels;
    diagnosis = labelInfo.Diagnosis;

    %                 figure(1);
    %                 imshow(hsiIm.GetDisplayImage());
    %                 b = vals{i};
    %                 malLabel = zeros(size(hsiIm.FgMask));
    %                 malLabel(b(1)-3:b(1)+3, b(2)-3:b(2)+3) = 1;
    %                 malLabel = hsiIm.FgMask & malLabel;
    malLabel = hsiIm.FgMask & labelImg;
    malData = mean(hsiIm.GetMaskedPixels(malLabel));
    k = k + 1;
    refLib(k).Data = malData;
    refLib(k).Label = 1;
    refLib(k).Diagnosis = diagnosis;

    plotPath = commonUtility.GetFilename('output', fullfile(config.GetSetting('ReferenceLibraryName'), strcat('ReferenceMask', num2str(k))), 'png');
    plots.Overlay(1, plotPath, hsiIm.GetDisplayImage(), malLabel);

    %                 benLabel = zeros(size(hsiIm.FgMask));
    %                 benLabel(b(3)-3:b(3)+3, b(4)-3:b(4)+3) = 1;
    %                 benLabel = hsiIm.FgMask & benLabel;
    benLabel = hsiIm.FgMask & ~labelImg;
    benData = mean(hsiIm.GetMaskedPixels(benLabel));
    k = k + 1;
    refLib(k).Data = benData;
    refLib(k).Label = 0;
    refLib(k).Diagnosis = diagnosis;

    plotPath = commonUtility.GetFilename('output', fullfile(config.GetSetting('ReferenceLibraryName'), strcat('ReferenceMask', num2str(k))), 'png');
    plots.Overlay(2, plotPath, hsiIm.GetDisplayImage(), benLabel);

end

labs = {'Benign', 'Malignant'};
suffix = cellfun(@(x) labs(x+1), {refLib.Label});
names = cellfun(@(x, y) strjoin({x, y}, {' '}), {refLib.Diagnosis}, suffix, 'UniformOutput', false);
plotPath = commonUtility.GetFilename('output', fullfile(config.GetSetting('ReferenceLibraryName'), 'references'), 'png');
plots.Spectra(3, plotPath, cell2mat({refLib.Data}'), hsiUtility.GetWavelengths(numel(refLib(1).Data)), ...
    names, 'SAM Library Spectra', {'-', ':', '-', ':'});

saveName = commonUtility.GetFilename('referenceLib', config.GetSetting('ReferenceLibraryName'));
save(saveName, 'refLib');
fprintf('The reference library is loaded from %s.\n', saveName);
end