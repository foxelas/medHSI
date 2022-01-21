function [values, valueNames, additionalValues] = GetColorchartValues(name)
%GetColorchartValues fetches expected values
%
%   Usage:
%   [values, valueNames, additionalValues] = GetColorchartValues() returns
%   the expected values for colorchart spectra
%
%   [values] = GetColorchartValues('colorchartRGB') returns the expected
%   values for colorchart RGB space
%
%   [values] = GetColorchartValues('colorchartLab') returns the
%   expected values for colorchart Lab space
%

if nargin < 1
    name = 'colorchartSpectra';
end

valueNames = [];
additionalValues = [];
switch name
    case 'colorchartSpectra'
        filename = fullfile(config.GetSetting('importDir'), 'ColorChecker_RGB_and_spectra.txt');
        outstruct = delimread(filename, '\t', {'text', 'num'});
        valueNames = outstruct.text;
        valueNames = valueNames(2:length(valueNames));
        additionalValues = outstruct.num(1, :);
        values = outstruct.num(2:end, :);

    case 'colorchartRGB'
        filename = fullfile(config.GetSetting('importDir'), 'ColorCheckerMicro_Matte_RGB_values.txt');
        outstruct = delimread(filename, '\t', 'num');
        values = outstruct.num;

    case 'colorchartLab'
        filename = fullfile(config.GetSetting('importDir'), 'ColorCheckerMicro_Matte_Lab_values.txt');
        outstruct = delimread(filename, '\t', 'num');
        values = outstruct.num;

    case 'colorchartOrder'
        colorPatchOrder = config.GetSetting('colorPatchOrder');
        if isempty(colorPatchOrder)
            colorPatchOrder = 'darkSkinBottom';
        end
        outstruct = delimread(fullfile(config.GetSetting('importDir'), strcat(colorPatchOrder, 'PatchOrder.txt')), '\t', 'text');
        values = outstruct.text;

    otherwise
        error('Unsupported name.')
end

end