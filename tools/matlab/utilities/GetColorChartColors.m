function [c] = GetColorChartColors(colorNames)
%     GETCOLORCHARTCOLORS returns double RGB color tripels that describe
%     the colors in the order of BABEL Colors colorimetric data.
%
%     Input args
%     colorNames [Optionsal]: list of color names required
%
%     Output args
%     c: colour triplets accoring to the colorchart color patch order
%
%     Dependencies
%     None
%
%     Usage:
%     c = GetColorChartColors();
%     The function returns color triplets that can be used e.g for
%     color spectra for the different color patches.

if nargin < 1
    colorNames = {'dark skin'; 'light skin'; 'blue sky'; 'foliage'; 'blue flower'; 'bluish green'; 'orange'; ...
        'purplish blue'; 'moderate red'; 'purple'; 'yellow green'; 'orange yellow'; 'blue'; 'green'; 'red'; ...
        'yellow'; 'magenta'; 'cyan'; 'white 9.5 (.05 D)'; 'neutral 8 (.23 D)'; 'neutral 6.5 (.44 D)'; ...
        'neutral 5 (.70 D)'; 'neutral 3.5 (1.05 D)'; 'black 2 (1.5 D)'};
end
c = zeros(length(colorNames), 3);

for i = 1:length(colorNames)
    switch colorNames{i}
        case 'dark skin'
            c(i, :) = [97, 63, 16];
        case 'light skin'
            c(i, :) = [214, 188, 152];
        case 'blue sky'
            c(i, :) = [94, 238, 215];
        case 'foliage'
            c(i, :) = [83, 132, 10];
        case 'blue flower'
            c(i, :) = [123, 104, 238];
        case 'bluish green'
            c(i, :) = [86, 233, 219];
        case 'orange'
            c(i, :) = [196, 76, 2];
        case 'purplish blue'
            c(i, :) = [92, 76, 163];
        case 'moderate red'
            c(i, :) = [168, 74, 74];
        case 'purple'
            c(i, :) = [144, 0, 231];
        case 'yellow green'
            c(i, :) = [202, 231, 0];
        case 'orange yellow'
            c(i, :) = [231, 173, 0];
        case 'blue'
            c(i, :) = [0, 0, 231];
        case 'green'
            c(i, :) = [0, 231, 0];
        case 'red'
            c(i, :) = [231, 0, 0];
        case 'yellow'
            c(i, :) = [231, 231, 0];
        case 'magenta'
            c(i, :) = [231, 0, 231];
        case 'cyan'
            c(i, :) = [0, 231, 231];
        case 'white 9.5 (.05 D)'
            c(i, :) = [229, 229, 229];
        case 'neutral 8 (.23 D)'
            c(i, :) = [178, 178, 178];
        case 'neutral 6.5 (.44 D)'
            c(i, :) = [153, 153, 153];
        case 'neutral 5 (.70 D)'
            c(i, :) = [76, 76, 76];
        case'neutral 3.5(1.05 D)'
            c(i, :) = [51, 51, 51];
        case 'black 2 (1.5 D)'
            c(i, :) = [0, 0, 0];
        otherwise
            c = [];
    end

end

if ~isempty(c)
    c = c / 255;
end
end