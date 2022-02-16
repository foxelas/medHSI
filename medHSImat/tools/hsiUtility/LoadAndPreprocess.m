function hsIm = LoadAndPreprocess(targetName, option, saveFile)
%LoadAndPreprocess returns spectral data from HSI image
%
%   Usage:
%   hsIm = LoadAndPreprocess('sample2') returns a
%   cropped HSI with 'byPixel' normalization
%
%   hsIm = LoadAndPreprocess('sample2', 'raw')
%   hsIm = LoadAndPreprocess('sample2', 'byPixel', true)

config.SetSetting('fileName', targetName);

if nargin < 2 || isempty(option)
    option = config.GetSetting('normalization');
end

hsIm = hsi(hsiUtility.LoadHSI(targetName));
if ~strcmp(option, 'raw')
    whiteReflectance = hsiUtility.LoadHSIReference(targetName, strcat('white_', option));
    blackReflectance = hsiUtility.LoadHSIReference(targetName, 'black');
    hsIm = hsIm.Normalize(whiteReflectance, blackReflectance);
end

%% Dependent on selected pre-processing
if ~strcmp(option, 'raw')
    fHndl = @Preprocessing;
    hsIm = fHndl(hsIm);
end

spectralData = hsIm;
% figure(4);imshow(squeeze(spectralData.Value(:,:,100)));

if saveFile
    filename = dataUtility.GetFilename('preprocessed', targetName);
    fprintf('Preprocessed data [spectralData] is saved at %s.\n', filename);
    save(filename, 'spectralData', '-v7.3');
end

end
