% ======================================================================
%> @brief Preprocessing data according to specifications.
%>
%> The setting config::[Normalization] needs to be set beforehand.
%>
%> YOU CAN CHANGE THIS FUNCTION ACCORDING TO YOUR SPECIFICATIONS.
%>
%> @b Usage
%>
%> @code
%> config.SetSetting('Normalization', 'byPixel');
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
% The setting config::[Normalization] needs to be set beforehand.
%
% YOU CAN CHANGE THIS FUNCTION ACCORDING TO YOUR SPECIFICATIONS.
%
% @b Usage
%
% @code
% config.SetSetting('Normalization', 'byPixel');
% [newI, idxs] = Preprocess(hsIm, targetID);
% @endcode
%
% @param obj [hsi] | An instance of the hsi class
% @param targetId [char] | The unique ID of the target sample
%
% @return instance of the hsi class

option = config.GetSetting('Normalization');

hasDenoising = false;

if ~strcmp(option, 'raw')

    %% Normalize
    whiteReflectance = hsiUtility.LoadHSIReference(targetID, strcat('white_', option));
    blackReflectance = hsiUtility.LoadHSIReference(targetID, 'black');
    hsIm = hsIm.Normalize(whiteReflectance, blackReflectance);

    %% Crop extreme spectra
    value = hsIm.Value;
    value = value(:, :, hsiUtility.GetWavelengths(311, 'index'));
    hsIm.Value = value;

    %% Remove background
    if ~isempty(hsIm.FgMask)
        col = hsIm.GetMaskedPixels(ones(size(hsIm.FgMask)), false);
        colMask = reshape(hsIm.FgMask, [size(hsIm.FgMask, 1) * size(hsIm.FgMask, 2), 1]);
        col(~colMask, :) = 0;
        value = hsi.RecoverSpatialDimensions(col, size(hsIm.FgMask));
        hsIm.Value = value;
    end

    %% Denoise (Currently disabled)
    if hasDenoising
        value = hsIm.Denoise('smoothen');
        hsIm.Value = value;
    end

end

end