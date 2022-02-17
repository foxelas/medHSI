function hsIm = LoadAndPreprocess(targetName, saveFile)
%LoadAndPreprocess returns spectral data from HSI image
%
%   Usage:
%   hsIm = LoadAndPreprocess('sample2') returns a
%   cropped HSI with 'byPixel' normalization
%
%   hsIm = LoadAndPreprocess('sample2')
%   hsIm = LoadAndPreprocess('sample2', true)

config.SetSetting('fileName', targetName);

if nargin < 2
    saveFile = false;
end

hsIm = hsi(hsiUtility.LoadHSI(targetName));
hsIm = Preprocessing(hsIm, targetName);

spectralData = hsIm;
% figure(4);imshow(squeeze(spectralData.Value(:,:,100)));

if saveFile
    filename = dataUtility.GetFilename('preprocessed', targetName);
    fprintf('Preprocessed data [spectralData] is saved at %s.\n', filename);
    save(filename, 'spectralData', '-v7.3');
end

end
