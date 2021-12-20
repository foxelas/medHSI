function spectralData = NormalizeHSI(targetName, option, saveFile)
%NormalizeHSI returns spectral data from HSI image
%
%   Usage:
%   spectralData = NormalizeHSI('sample2') returns a
%   cropped HSI with 'byPixel' normalization
%
%   spectralData = NormalizeHSI('sample2', 'raw')
%   spectralData = NormalizeHSI('sample2', 'byPixel', true)

SetSetting('fileName', targetName);

if nargin < 2 || isempty(option)
    option = GetSetting('normalization');
end

baseDir = fullfile(GetSetting('matDir'), strcat(GetSetting('database'), 'Triplets'), targetName);

targetFilename = strcat(baseDir, '_target.mat');
load(targetFilename, 'spectralData');
hsIm = Hsi;
hsIm.Value = spectralData;
[m, n, w] = hsIm.Size();

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
        hsIm = hsIm.Minus(blackReflectance);

    otherwise
        error('Unsupported setting for normalization.');
end

if useBlack
    if ~isequal(hsIm.Size(), size(blackReflectance))
        error('Not implemented error');
        %cropMask = getCaptureROImask(m, n);
        blackReflectance = blackReflectance(any(cropMask, 2), any(cropMask, 1), :);
        warning('Crop the image value: black');
    end
    if ~isequal(hsIm.Size(), size(whiteReflectance))
        error('Not implemented error');
        %cropMask = getCaptureROImask(m, n);
        whiteReflectance = whiteReflectance(any(cropMask, 2), any(cropMask, 1), :);
        warning('Crop the image value: white');
    end
    hsIm = hsIm.Normalize(whiteReflectance, blackReflectance);
end

hsIm = hsIm.Max(0);
hsIm = hsIm.Update(hsIm.IsNan(), 0);
hsIm = hsIm.Update(hsIm.IsInf(), 0);

%% Dependent on selected pre-processing
if ~strcmp(option, 'raw')
    fHndl = @Preprocessing;
    hsIm = fHndl(hsIm);
end

spectralData = hsIm.Value;
% figure(4);imshow(squeeze(spectralData(:,:,100)));

if saveFile
    baseDir = Config.DirMake(Config.GetSetting('matDir'), ...
        strcat(Config.GetSetting('database'), 'Normalized'), targetName);

    targetFilename = strcat(baseDir, '_', Config.GetSetting('normalization'), '.mat');
    save(targetFilename, 'spectralData', '-v7.3');
end

end