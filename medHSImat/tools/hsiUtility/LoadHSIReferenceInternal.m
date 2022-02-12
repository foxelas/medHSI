function [spectralData] = LoadHSIReferenceInternal(targetName, refType)
% LoadHSIReferenceInternal reads a stored HSI reference according to refType
%
%   Usage:
%   [spectralData] = LoadHSIReferenceInternal(targetName, 'white')
%   [spectralData] = LoadHSIReferenceInternal(targetName, 'black')

if isnumeric(targetName)
    targetName = num2str(targetName);
end

if contains(refType, 'white')
    targetFilename = dataUtility.GetFilename('white', targetName);        
    if contains(refType, 'byPixel') || strcmpi(refType, 'white')
            load(targetFilename, 'fullReflectanceByPixel');
            spectralData = fullReflectanceByPixel;

    elseif contains(refType, 'uniSpectrum')
            load(targetFilename, 'uniSpectrum');
            spectralData = uniSpectrum;

    elseif contains(refType, 'bandmax')
            load(targetFilename, 'bandmaxSpectrum');
            spectralData = bandmaxSpectrum;

    else 
        error('Not supported.');
    end

elseif contains(refType, 'black')
    targetFilename = dataUtility.GetFilename('black', targetName);
    load(targetFilename, 'blackReflectance')
    spectralData = blackReflectance;
else 
    error('Not supported.');
end

end