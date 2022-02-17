function  [hsIm] = Preprocessing(hsIm, targetName)
    % Preprocessing prepares data according to our specifications
    % Any type of preprocessing should be included here
    %
    %   Usage:
    %   pHsi = Preprocessing(hsi, targetName);
    %
    %   YOU CAN CHANGE THIS FUNCTION ACCORDING TO YOUR SPECIFICATIONS

    option = config.GetSetting('normalization');
    
    if ~strcmp(option, 'raw')
        %%Normalize
        whiteReflectance = hsiUtility.LoadHSIReference(targetName, strcat('white_', option));
        blackReflectance = hsiUtility.LoadHSIReference(targetName, 'black');
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