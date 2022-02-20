%======================================================================
%> @brief LoadHSIReferenceInternal reads the reference hyperspectral image (white or black).
%>
%> It is valid for hyperspectral data already saved as .mat files
%> in config::[matdir]\[tripletsName]\*_white.mat or *_black.mat.
%> The returned reference image is a 3D array, not an hsi instance.
%>
%> @b Usage
%>
%> @code
%> [spectralData] = hsiUtility.LoadHSIReferenceInternal('150', 'white');
%>
%> [spectralData] = hsiUtility.LoadHSIReferenceInternal('150', 'black');
%> @endcode
%>
%> @param targetId [char] | The unique ID of the target sample
%> @param refType [char] | The reference type, either 'white' or
%> 'black'
%>
%> @retval spectralData [numeric array] | A 3D array of the
%> hyperspectral image reference
%======================================================================
function [spectralData] = LoadHSIReferenceInternal(targetName, refType)
% LoadHSIReferenceInternal reads the reference hyperspectral image (white or black).
%
% It is valid for hyperspectral data already saved as .mat files
% in config::[matdir]\[tripletsName]\*_white.mat or *_black.mat.
% The returned reference image is a 3D array, not an hsi instance.
%
% @b Usage
%
% @code
% [spectralData] = LoadHSIReferenceInternal('150', 'white');
%
% [spectralData] = LoadHSIReferenceInternal('150', 'black');
% @endcode
%
% @param targetId [char] | The unique ID of the target sample
% @param refType [char] | The reference type, either 'white' or
% 'black'
%
% @retval spectralData [numeric array] | A 3D array of the
% hyperspectral image reference

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