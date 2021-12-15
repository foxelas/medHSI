classdef hsi
    properties
        Value {mustBeNumeric}
    end
    methods
%% Contents 
%
%   Non-Static:
%         Size
%         Dimred
%         NormalizeImage
%         GetDisplayImage
%         GetPixelsFromMask
%         GetMaskFromFigure
%         GetFgMask
%         GetSpectraFromMask
%         GetQualityPixels
%         RemoveBackground
%         GetBandCorrelation
%         Preprocessing
%
        function [m, n, w] = Size(obj)
            [m, n, w] = size(obj.Value);
        end
        
        function [coeff, scores, latent, explained, objective] = Dimred(obj, method, q, mask)
            [coeff, scores, latent, explained, objective] = DimredHSI(obj.Value, method, q, mask);
        end
        
        function normI = NormalizeImage(obj, white, black, method)
            normI = NormalizeImage(obj.Value, white, black, method);
        end
        
        function dispImage = GetDisplayImage(obj, method, channel)
            dispImage = GetDisplayImage(obj.Value, method, channel);
        end
        
        function [maskedPixels] = GetPixelsFromMask(obj, mask)
            maskedPixels = GetPixelsFromMask(obj.Value, mask);
        end
        
        function [mask, maskedPixels] = GetMaskFromFigure(obj)
            [mask, maskedPixels] = GetMaskFromFigure(obj.Value);
        end 
        
        function fgMask = GetFgMask(obj)
            fgMask = GetFgMask(obj.Value);
        end
        
        function spectrumCurves = GetSpectraFromMask(obj, subMasks, targetMask)
             spectrumCurves = GetSpectraFromMask(obj.Value, subMasks, targetMask);
        end
        
        function [newI, idxs] = GetQualityPixels(obj, meanLimit, maxLimit)
            [newI, idxs] = GetQualityPixels(obj.Value, meanLimit, maxLimit);
        end
        
        function [updI, fgMask] = RemoveBackground(obj, colorLevelsForKMeans, attemptsForKMeans, bigHoleCoefficient, closingCoefficient, openingCoefficient)
            [updI, fgMask] = RemoveBackground(obj.Value, colorLevelsForKMeans, attemptsForKMeans, bigHoleCoefficient, closingCoefficient, openingCoefficient);
        end
        
        function [c] = GetBandCorrelation(obj, hasPixelSelection)
            %     GETBANDCORRELATION returns the array of band correlation for an msi I
            %
            %     Usage:
            %     [c] = GetBandCorrelation(I)
            %     [c] = GetBandCorrelation(I, hasPixelSelection)

            if nargin < 2
                hasPixelSelection = false;
            end

            hsi = obj.Value;
            if ndims(hsi) > 2
                [b, m, n] = size(hsi);
                hsi = reshape(hsi, b, m*n)';
            end

            if hasPixelSelection
                spectralMean = mean(hsi, 2);
                spectralMax = max(hsi, [], 2);
                acceptablePixels = spectralMean > 0.2 & spectralMax < 0.99;
                tempI = hsi(acceptablePixels, :);
            else
                tempI = hsi;
            end
            c = corr(tempI);
        end
        
        function [pHsi] = Preprocessing(obj)
        % Preprocessing prepares normalized data according to our specifications
        %
        %   Usage:
        %   pHsi = Preprocessing(hsi);
        %
        %   YOU CAN CHANGE THIS FUNCTION ACCORDING TO YOUR SPECIFICATIONS

        hsi = obj.Value;
        hsi = hsi(:, :, [420:730]-380);
        [updI, ~] = RemoveBackground(hsi);
        pHsi = updI;

        end
    end
    
end