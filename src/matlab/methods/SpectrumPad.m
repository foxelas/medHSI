function [outSpectrum] = SpectrumPad(inSpectrum, options)
%SPECTRUMPAD adds or removes padding to spectrum array
%
%   Usage:
%   [outSpectrum] = SpectrumPad(inSpectrum) adds padding to inSpectrum
%   [outSpectrum] = SpectrumPad(inSpectrum, 'add') adds padding to inSpectrum
%   [outSpectrum] = SpectrumPad(inSpectrum, 'del') removes padding from inSpectrum

if nargin < 2
    options = 'add';
end

m = length(inSpectrum);

switch options
    case 'add'
        x = getWavelengths(m, 'index');
        if m > 100
            outSpectrum = zeros(401, 1);
        else
            outSpectrum = zeros(36, 1);
        end
        outSpectrum(x) = inSpectrum;

    case 'del'
        isPadded = true;
        if m == 36
            cutoff = 15;
        elseif m == 401
            cutoff = 150;
        else
            isPadded = false;
        end

        if isPadded && isempty(nonzeros(inSpectrum(1:cutoff)))
            idStart = find(inSpectrum, 1);
            outSpectrum = inSpectrum(idStart:end);

        elseif isPadded && isempty(nonzeros(inSpectrum((end -cutoff):end)))
            idEnd = find(inSpectrum, 1, 'last');
            outSpectrum = inSpectrum(1:idEnd);

        else
            outSpectrum = inSpectrum;
        end

    otherwise
        error('Unsupported options');
end
end