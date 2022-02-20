% ======================================================================
%> @brief Preprocessing data according to specifications.
%>
%> The setting config::'normalization' needs to be set beforehand.
%>
%> YOU CAN CHANGE THIS FUNCTION ACCORDING TO YOUR SPECIFICATIONS.
%>
%> @b Usage
%>
%> @code
%> config.SetSetting('normalization', 'byPixel');
%> [newI, idxs] = Preprocess(hsIm, targetID);
%> @endcode
%>
%> @param obj [hsi] | An instance of the hsi class
%> @param targetId [char] | The unique ID of the target sample
%>
%> @return instance of the hsi class
% ======================================================================
function [hsIm] = Preprocessing(hsIm, targetID)
% Preprocessing data according to specifications.
%
% The setting config::'normalization' needs to be set beforehand.
%
% YOU CAN CHANGE THIS FUNCTION ACCORDING TO YOUR SPECIFICATIONS.
%
% @b Usage
%
% @code
% config.SetSetting('normalization', 'byPixel');
% [newI, idxs] = Preprocess(hsIm, targetID);
% @endcode
%
% @param obj [hsi] | An instance of the hsi class
% @param targetId [char] | The unique ID of the target sample
%
% @return instance of the hsi class

option = config.GetSetting('normalization');

if ~strcmp(option, 'raw')
    %%Normalize
    whiteReflectance = hsiUtility.LoadHSIReference(targetID, strcat('white_', option));
    blackReflectance = hsiUtility.LoadHSIReference(targetID, 'black');
    hsIm = hsIm.Normalize(whiteReflectance, blackReflectance);

    value = hsIm.Value;

    %%Crop extreme spectra
    value = value(:, :, hsiUtility.GetWavelengths(311, 'index'));

    %%Remove background
    hsIm.Value = value;
    [updI, fgMask] = hsIm.RemoveBackground();
    hsIm.Value = updI;
    hsIm.FgMask = fgMask;
end
end