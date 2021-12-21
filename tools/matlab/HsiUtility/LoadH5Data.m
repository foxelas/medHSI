function [spectralData, imageXYZ, wavelengths] = LoadH5Data(filename)
%LOADH5DATA loads info from h5 file
%
%   Usage:
%   [spectralData, imageXYZ, wavelengths] = LoadH5Data(filename)
%   returns spectralData, XYZ image and capture wavelengths

database = config.GetSetting('database');
filename = strrep(filename, '.hsm', '.h5');
saveFilename = config.DirMake(config.GetSetting('matDir'), database, strcat(filename, '.mat'));

if ~exist(saveFilename, 'file')
    currentFile = AdjustFilename(filename);
    %h5disp(currentFile);
    %h5info(currentFile);

    spectralData = double(h5read(currentFile, '/SpectralImage'));

    wavelengths = h5read(currentFile, '/Wavelengths');
    imageX = h5read(currentFile, '/MeasurementImages/Tristimulus_X');
    imageY = h5read(currentFile, '/MeasurementImages/Tristimulus_Y');
    imageZ = h5read(currentFile, '/MeasurementImages/Tristimulus_Z');
    imageXYZ = cat(3, imageX, imageY, imageZ);

    save(saveFilename, 'spectralData', 'imageXYZ', 'wavelengths', '-v7.3');
else
    load(saveFilename, 'spectralData', 'imageXYZ', 'wavelengths');
end

end

function currentFile = AdjustFilename(filename)
inDir = config.GetSetting('dataDir');

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