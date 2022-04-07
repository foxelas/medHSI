%======================================================================
%> @brief LoadH5Data loads the hyperspectral image from an .h5 file.
%>
%> The .h5 data are assumed to be saved in config::[DataDir]\\*.h5
%> After reading, the image is saved in config::[MatDir]\\[Database]\\*.mat.
%>
%> @ Usage
%>
%> @code
%> [spectralData, imageXYZ, wavelengths] = LoadH5Data(filename);
%> @endcode
%>
%> @param filename [char] | The filename of the file to read
%>
%> @retval spectralData [numeric array] | The hyperspectral image
%> @retval imageXYZ [numeric array] | The XYZ image
%> @retval wavelengths [numeric array] | The spectral wavelengths
%======================================================================
function [spectralData, imageXYZ, wavelengths] = LoadH5Data(filename)
%> @brief LoadH5Data loads the hyperspectral image from an .h5 file.
%>
%> The .h5 data are assumed to be saved in config::[DataDir]\\*.h5
%> After reading, the image is saved in config::[MatDir]\\[Database]\\*.mat.
%>
%> @ Usage
%> @code
%> [spectralData, imageXYZ, wavelengths] = LoadH5Data(filename);
%> @endcode
%>
%> @param filename [char] | The filename of the file to read
%>
%> @retval spectralData [numeric array] | The hyperspectral image
%> @retval imageXYZ [numeric array] | The XYZ image
%> @retval wavelengths [numeric array] | The spectral wavelengths
filename = strrep(filename, '.hsm', '.h5');
saveFilename = commonUtility.GetFilename('h5', filename);

if ~exist(saveFilename, 'file')
    currentFile = AdjustFilename(filename);
    %h5disp(currentFile);
    %h5info(currentFile);

    if exist(currentFile) > 0
        spectralData = double(h5read(currentFile, '/SpectralImage'));

        wavelengths = h5read(currentFile, '/Wavelengths');
        imageX = h5read(currentFile, '/MeasurementImages/Tristimulus_X');
        imageY = h5read(currentFile, '/MeasurementImages/Tristimulus_Y');
        imageZ = h5read(currentFile, '/MeasurementImages/Tristimulus_Z');
        imageXYZ = cat(3, imageX, imageY, imageZ);
    else
        spectralData = [];
        imageXYZ = [];
        wavelengths = [];
        fprintf('File does not exist.\nDirectory %s\n', currentFile);
    end

    save(saveFilename, 'spectralData', 'imageXYZ', 'wavelengths', '-v7.3');
else
    load(saveFilename, 'spectralData', 'imageXYZ', 'wavelengths');
end

end

function currentFile = AdjustFilename(filename)
inDir = fullfile(config.GetSetting('DataDir'), config.GetSetting('DataFolderName'));

% filenameParts = strsplit(filename, '_');
% dataDate = filenameParts{1};
% if ~contains(inDir, dataDate)
%     filenameParts = strsplit(inDir, '\\saitama');
%     ending = filenameParts{2};
%     filenameParts = strsplit(ending, '_');
%     oldDate = filenameParts{1};
%     inDir = strrep(inDir, oldDate, dataDate);
% end

currentFile = fullfile(inDir, filename);
if ~contains(currentFile, '.h5')
    currentFile = strcat(currentFile, '.h5');
end
end