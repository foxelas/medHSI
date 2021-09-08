function [outname] = StrrepAll(inname, isLegacy)
%     StrrepAll fomats an inname to outname
%
%     Usage:
%     [outname] = StrrepAll(inname)

if nargin < 2
    isLegacy = false;
end

[~, outname] = fileparts(inname);

str = '_';
if isLegacy
    str = ' ';
end

outname = strrep(outname, '\', str);
outname = strrep(outname, '_', str);
outname = strrep(outname, ' ', str);

outname = strrep(outname, '.csv', '');
outname = strrep(outname, '.mat', '');

end