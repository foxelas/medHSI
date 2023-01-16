%======================================================================
%> @brief PrepareLabelsFromLabelMe prepares labels in the DataDir after the labelme labels have been created.
%>
%> You can modify this function, according to your data structure.
%>
%> Reads img.png files created by Labelme and prepares black and white label masks.
%>
%> @b Usage
%> @code
%> initUtility.PrepareLabelsFromLabelMe('02-Labelme', 'pslRaw', {'tissue', true}, {'raw', false});
%> @endcode
%>
%> @param inputFolder [string] | The input folder where the labelme output is located. It should exist under config::[Dataset]/dataset/.
%> @param dataset [string] | The name of target dataset
%> @param  contentConditions [cell array] | The content conditions for reading files
%> @param targetConditions [cell array] | Optional: The target conditions for reading files. Default: none.
%======================================================================
function [] = PrepareLabelsFromLabelMe(inputFolder, dataset, contentConditions, targetConditions)

config.SetSetting('Dataset', dataset);
config.SetSetting('SaveFolder', inputFolder);

%% Read h5 data
if nargin < 4
    [~, targetIDs, outRows] = databaseUtility.Query(contentConditions);
else
    [~, targetIDs, outRows] = databaseUtility.Query(contentConditions, [], [], [], [], targetConditions);
end

c = 0;
for i = 1:length(targetIDs)

    targetID = num2str(targetIDs(i));

    if logical(outRows{i, 'IsUnfixed'}{1})
        tissueType = 'Unfixed';
    else
        tissueType = 'Fixed';
    end

    config.SetSetting('FileName', targetID);

    isSuccess = GetLabelFromLabelMe(targetID, tissueType);
    c = c + isSuccess;
end

fprintf('\nA total of %d labels were prepared.\n\n', c);

end


function isSuccess = GetLabelFromLabelMe(targetID, tissueType)

config.SetSetting('SaveFolder', '00-Labelme');
savedir = commonUtility.GetFilename('output', config.GetSetting('SaveFolder'), '');
imgFile = fullfile(savedir, targetID, 'img.png');

if exist(imgFile) > 0
    img = imread(imgFile);
    lab = double(imread(fullfile(savedir, targetID, 'label.png')));

    figure(1);
    imshow(img);
    title(strcat('Input:', targetID));
    figure(2);
    imagesc(lab);
    title(strcat('Label:', targetID));

    saveLabelFolder = config.DirMake(config.GetSetting('DataDir'), config.GetSetting('LabelsFolderName'), tissueType, strcat(targetID, '.png'));
    imwrite(lab, saveLabelFolder);
    isSuccess = true;
else 
    fprintf('Label files for targetID %s do not exist in %s.\n', targetID, imgFile);
    isSuccess = false;
end

end