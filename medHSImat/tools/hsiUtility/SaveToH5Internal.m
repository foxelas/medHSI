%======================================================================
%> @brief SaveToH5Internal saves the data of a set of target ids as a dataset in .hdf5
%> format.
%>
%> This function aggregates all small .mat files in a large .hdf5 dataset.
%> The dataset is assumed from config::[MatDir]\\config::[Dataset]\\*.mat.
%>
%> If the data is not instances of the hsi class, then only the hsi cube values are saved.
%>
%> @b Usage
%>
%> @code
%> config.SetSetting('Dataset', 'pslRaw');
%> [~, targetIDs] = commonUtility.DatasetInfo();
%> targetIDs = targetIDs(contains(targetIDs, '15'));
%> saveName = '150_set.h5';
%> hsiUtility.SaveToH5(targetIDs, saveName);
%> @endcode
%>
%> @param targetIDs [cell array] | The target IDs of target hsi cubes.
%> @param saveName [char] | The save name for the .h5 file.
%======================================================================
function [] = SaveToH5Internal(targetIDs, saveName)

if exist(saveName, 'file') > 0
    disp('Deleting previously exported .h5 dataset.');
    delete(saveName);
end

n = length(targetIDs);

needsToLoad = ~isstruct(targetIDs);
if ~needsToLoad
    sp = [targetIDs.SpectralData];
    lb = [targetIDs.LabelInfo];
    targetIDs = {targetIDs.TargetID};
end

for i = 1:n
    targetName = num2str(targetIDs{i});
    if needsToLoad

        %% load HSI from .mat file
        [spectralData, labelInfo] = hsiUtility.LoadHsiAndLabel(targetName);
    else
        spectralData = sp(i);
        labelInfo = lb(i);
    end

    if (hsi.IsHsi(spectralData))

        dataValue = spectralData.Value;
        dataMask = uint8(spectralData.FgMask);
        label = labelInfo.Labels;
        if isempty(label)
            label = nan;
            multiclassLabel = nan;
        else
            multiclassLabel = labelInfo.MultiClassLabels;
        end
        if strcmpi(labelInfo.Type, 'Malignant')
            diagnosticLabel = 1;
        else
            diagnosticLabel = 0;
        end
        sampleID = str2num(spectralData.SampleID);
        targetID = str2num(spectralData.ID);

        curName = strcat('/sample', targetName, '/hsi');
        h5create(saveName, curName, size(dataValue));
        h5write(saveName, curName, dataValue);

        curName = strcat('/sample', targetName, '/mask');
        h5create(saveName, curName, size(dataMask));
        h5write(saveName, curName, dataMask);

        curName = strcat('/sample', targetName, '/label');
        h5create(saveName, curName, size(label));
        h5write(saveName, curName, label);

        curName = strcat('/sample', targetName, '/diagnosticLabel');
        h5create(saveName, curName, size(diagnosticLabel));
        h5write(saveName, curName, diagnosticLabel);

        curName = strcat('/sample', targetName, '/multiclassLabel');
        h5create(saveName, curName, size(multiclassLabel));
        h5write(saveName, curName, multiclassLabel);

        curName = strcat('/sample', targetName, '/sampleID');
        h5create(saveName, curName, size(sampleID));
        h5write(saveName, curName, sampleID);

        curName = strcat('/sample', targetName, '/targetID');
        h5create(saveName, curName, size(targetID));
        h5write(saveName, curName, targetID);

    else
        dataValue = spectralData;
        curName = strcat('/hsi/sample', targetName);
        h5create(saveName, curName, size(dataValue));
        h5write(saveName, curName, dataValue);
    end
end

% h5disp(fileName);
fprintf('Saved .h5 dataset at %s.\n\n', saveName);
end