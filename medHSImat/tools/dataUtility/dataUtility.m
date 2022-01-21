classdef dataUtility
    methods (Static)

        %% Contents
        %
        %   Static:
        %         [outname] = StrrepAll(inname, isLegacy)
        %         [value] = GetValueFromTable(tab, field, id)
        %         [bbox] = GetBoundingBoxMask(corners)
        %         [newSpectrum, newX] = SpectrumCut(oldSpectrum, x)
        %         [outSpectrum] = SpectrumPad(inSpectrum, options)
        %         [reorderedSpectra, labels] = ReorderSpectra(target, chartColorOrder, spectraColorOrder, wavelengths, spectralWavelengths)

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

        function [value] = GetValueFromTable(tab, field, id)
            %%GETVALUEFROMTABLE get a value from specific column in a table
            %
            %   Usage:
            %   value = GetValueFromTable(tab, field, id)

            column = tab.(field);
            value = column{id};
        end

        function [bbox] = GetBoundingBoxMask(corners)
            %     GETBOUNDINGBOX returns the settings for a bounding box from the mask indexes
            %
            %     Usage:
            %     bbox = GetBoundingBoxMask(corners)
            %
            %     Example
            %     corners = [316, 382, 242, 295];
            %     bbox = GetBoundingBoxMask(corners);
            %     returns bboxHb = [316 242 382-316 295-242];

            bbox = [corners(1), corners(3), corners(2) - corners(1) + 1, corners(4) - corners(3) + 1];

        end

        function [newSpectrum, newX] = SpectrumCut(oldSpectrum, x)
            %SPECTRUMCUT removes noisy bands from the spectrum
            %
            %   Usage:
            %   [newSpectrum, newX] = SpectrumCut(oldSpectrum, 380:780)

            ids = x >= 420 & x <= 730;
            newX = x(ids);
            newSpectrum = oldSpectrum(ids);
        end

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
                    x = hsiUtility.GetWavelengths(m, 'index');
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

        function [reorderedSpectra, labels] = ReorderSpectra(target, chartColorOrder, spectraColorOrder, wavelengths, spectralWavelengths)
            %REORDERSPECTRA match chartColorOrder according to spectralColorOrder
            % i.e. match babel order to colorchart order
            %
            %   Usage:
            %    [reorderedSpectra, labels] = ReorderSpectra(target, chartColorOrder,
            %       spectraColorOrder, wavelengths, spectralWavelengths)

            if size(target, 2) == 401
                wavelengths = wavelengths;
            elseif size(target, 2) == 161
                wavelengths = [380:540]';
            else
                wavelengths = [541:780]';
            end

            [~, idx] = ismember(spectraColorOrder, chartColorOrder);
            idx = nonzeros(idx);
            [~, idx2] = ismember(spectralWavelengths', wavelengths);

            idx2 = nonzeros(idx2);

            targetDecim = target(:, idx2);
            reorderedSpectra = targetDecim(idx, :);

            labels = spectraColorOrder;
        end

    end
end