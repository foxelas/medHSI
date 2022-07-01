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
% PrepareLabelsFromLabelMe prepares labels in the DataDir after the labelme labels have been created.
%
% You can modify this function, according to your data structure. 
%
% Reads img.png files created by Labelme and prepares black and white label masks.
% 
% @b Usage
% @code
% initUtility.PrepareLabelsFromLabelMe('02-Labelme', 'pslRaw', {'tissue', true}, {'raw', false});
% @endcode
%
% @param inputFolder [string] | The input folder where the labelme output is located. It should exist under config::[Dataset]/dataset/. 
% @param dataset [string] | The name of target dataset
% @param  contentConditions [cell array] | The content conditions for reading files
% @param targetConditions [cell array] | Optional: The target conditions for reading files. Default: none.

config.SetSetting('Dataset', dataset);
config.SetSetting('SaveFolder', inputFolder);

%% Read h5 data
if nargin < 4
    [~, targetIDs, outRows] = databaseUtility.Query(contentConditions);
else
    [~, targetIDs, outRows] = databaseUtility.Query(contentConditions, [], [], [], [], targetConditions);
end

for i = 1:length(targetIDs)
    
    id = targetIDs(i);
    targetID = num2str(id);
    
    if (outRows(id).IsUnfixed)
        tissueType = 'Unfixed';
    else
        tissueType = 'Fixed';
    end
    
    config.SetSetting('FileName', targetID);

    GetLabelFromLabelMe(targetID, tissueType);
end

end



function [] = GetLabelFromLabelMe(targetID, tissueType)

config.SetSetting('SaveFolder', '00-Labelme');
savedir = commonUtility.GetFilename('output', config.GetSetting('SaveFolder'), '');

if exist(fullfile(savedir, targetID, 'img.png')) > 0
    img = imread(fullfile(savedir, targetID, 'img.png'));
    lab = double(imread(fullfile(savedir, targetID, 'label.png')));
    
    figure(1);
    imshow(img); title(strcat('Input:', targetID));
    figure(2);
    imagesc(lab); title(strcat('Label:', targetID));

    saveLabelFolder = config.DirMake(config.GetSetting('DataDir'), config.GetSetting('LabelsFolderName'), tissueType, strcat(targetID, '.png'));
    imwrite(lab, saveLabelFolder);
end

end