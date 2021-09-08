function [values, valueNames, additionalValues] = GetExpectedValues(name, option)
%GETEXPECTEDVALUES fetches expected values
%
%   Usage:
%   [values, valueNames, additionalValues] = GetExpectedValues() returns
%   the expected values for colorchart spectra
%
%   [values] = GetExpectedValues('colorchartRGB') returns the expected
%   values for colorchart RGB space
%
%   [values] = GetExpectedValues('colorchartLab') returns the
%   expected values for colorchart Lab space
%
%   [values] = GetExpectedValues('colorchartOrder',
%   'capture_average_comparison') returns the expected values for
%   colorchart patch order
%

if nargin < 1
    name = 'colorchartSpectra';
end

valueNames = [];
additionalValues = [];
switch name
    case 'colorchartSpectra'
        filename = fullfile(getSetting('importDir'), 'ColorChecker_RGB_and_spectra.txt');
        outstruct = delimread(filename, '\t', {'text', 'num'});
        valueNames = outstruct.text;
        valueNames = valueNames(2:length(valueNames));
        additionalValues = outstruct.num(1, :);
        values = outstruct.num(2:end, :);

    case 'colorchartRGB'
        filename = fullfile(getSetting('importDir'), 'ColorCheckerMicro_Matte_RGB_values.txt');
        outstruct = delimread(filename, '\t', 'num');
        values = outstruct.num;

    case 'colorchartLab'
        filename = fullfile(getSetting('importDir'), 'ColorCheckerMicro_Matte_Lab_values.txt');
        outstruct = delimread(filename, '\t', 'num');
        values = outstruct.num;

    case 'colorchartOrder'
        colorPatchOrder = getSetting('colorPatchOrder');
        if isempty(colorPatchOrder)
            colorPatchOrder = 'darkSkinBottom';
        end
        outstruct = delimread(fullfile(getSetting('datasetSettingsDir'), strcat(colorPatchOrder, 'PatchOrder.txt')), '\t', 'text');
        values = outstruct.text;

    otherwise
        error('Unsupported name.')
end

end