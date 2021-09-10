function spectralData = NormalizeHSI(targetName, option, saveFile)
%NormalizeHSI returns spectral data from HSI image
%
%   Usage:
%   spectralData = NormalizeHSI('sample2') returns a
%   cropped HSI with 'byPixel' normalization
%
%   spectralData = NormalizeHSI('sample2', 'raw')
%   spectralData = NormalizeHSI('sample2', 'byPixel', true)


if nargin < 2 || isempty(option)
    option = GetSetting('normalization');
end

baseDir = fullfile(GetSetting('matDir'), strcat(GetSetting('database'), 'Triplets'), targetName);

targetFilename = strcat(baseDir, '_target.mat');
load(targetFilename, 'spectralData');
[m, n, w] = size(spectralData);

whiteFilename = strcat(baseDir, '_white.mat');

useBlack = true;
if useBlack && ~strcmp(option, 'raw')
    blackFilename = strcat(baseDir, '_black.mat');
    load(blackFilename, 'blackReflectance');
end

switch option
    case 'raw'
        %do nothing
        useBlack = false;

    case 'byPixel'
        load(whiteFilename, 'fullReflectanceByPixel');
        whiteReflectance = fullReflectanceByPixel;
        clear 'fullReflectanceByPixel';

    case 'uniSpectrum'
        load(whiteFilename, 'uniSpectrum');
        whiteReflectance = reshape(repmat(uniSpectrum, m*n, 1), m, n, w);

    case 'bandmax'
        load(whiteFilename, 'bandmaxSpectrum');
        whiteReflectance = reshape(repmat(bandmaxSpectrum, m*n, 1), m, n, w);

    case 'forExternalNormalization'
        useBlack = false;
        spectralData = (spectralData - blackReflectance);

    otherwise
        error('Unsupported setting for normalization.');
end

if useBlack
    if ~isequal(size(spectralData), size(blackReflectance))
        cropMask = getCaptureROImask(m, n);
        blackReflectance = blackReflectance(any(cropMask, 2), any(cropMask, 1), :);
        warning('Crop the image value: black');
    end
    if ~isequal(size(spectralData), size(whiteReflectance))
        cropMask = getCaptureROImask(m, n);
        whiteReflectance = whiteReflectance(any(cropMask, 2), any(cropMask, 1), :);
        warning('Crop the image value: white');
    end
    NormalizeImage(spectralData, whiteReflectance, blackReflectance);
end

spectralData = max(spectralData, 0);
spectralData(isnan(spectralData)) = 0;
spectralData(isinf(spectralData)) = 0;

% figure(4);imshow(squeeze(spectralData(:,:,100)));

if saveFile
    baseDir = DirMake(GetSetting('matDir'), ...
        strcat(GetSetting('database'), 'Normalized'), targetName);

    targetFilename = strcat(baseDir, '_', GetSetting('normalization'), '.mat');
    save(targetFilename, 'spectralData');
end

end
