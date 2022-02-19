%> @file  LoadAndPreprocess.m
%======================================================================
%> @brief LoadAndPreprocess returns spectral data from HSI image
%>
%> Requires data to be read in a .mat file before-hand.
%>
%> @b Usage:
%> 
%> @code
%> % To read and preprocess a file with ID = 158
%> hsIm = LoadAndPreprocess('158');
%> 
%> % To read, preprocess and save a file with ID = 158
%> config.SetSetting('normalization', 'byPixel');
%> hsIm = LoadAndPreprocess('158', true);
%> % The preprocessed file is saved in
%> % matfiles\hsi\pslNormalized\158_byPixel.mat
%> @endcode
%> 
%> Preprocessed data file is saved with the same filename in a folder
%> according to config -> 'normalization'.
%>
%> @param targetName [str] | The filename of the target
%> @param saveFile [bool] | Whether to save the preprocessed file or not
%>
%> @retval hsIm [hsi] | The preprocessed spectral image
%>
%======================================================================
function hsIm = LoadAndPreprocess(targetName, saveFile)
%> @brief LoadAndPreprocess returns spectral data from HSI image
%>
%> Requires data to be read in a .mat file before-hand.
%>
%> @b Usage:
%> 
%> @code
%> % To read and preprocess a file with ID = 158
%>
%> hsIm = LoadAndPreprocess('158');
%> 
%> % To read, preprocess and save a file with ID = 158
%>
%> config.SetSetting('normalization', 'byPixel');
%> hsIm = LoadAndPreprocess('158', true);
%>
%> % The preprocessed file is saved in
%> % matfiles\hsi\pslNormalized\158_byPixel.mat
%> @endcode
%> 
%> Preprocessed data file is saved with the same filename in a folder
%> according to config -> 'normalization'.
%>
%> @param targetName [str] | The filename of the target
%> @param saveFile [bool] | Whether to save the preprocessed file or not
%>
%> @retval hsIm [hsi] | The preprocessed spectral image

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
