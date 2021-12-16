classdef hsi
    properties
        Value {mustBeNumeric}
    end
    methods
%% Contents 
%
%   Non-Static:
%         [setId] = SelectDatabaseSamples(dataTable, setId)
%         [coeff, scores, latent, explained, objective] = Dimred(obj, method, q, mask)
%         [obj] = Normalize(obj, white, black, method)
%         [dispImage] = GetDisplayImage(obj, method, channel)
%         [dispImage] = GetDisplayRescaledImage(obj, method, channel)
%         [maskedPixels] = GetPixelsFromMask(obj, mask)
%         [mask, maskedPixels] = GetMaskFromFigure(obj)
%         [fgMask] = GetFgMask(obj)
%         [spectrumCurves] = GetSpectraFromMask(obj, subMasks, targetMask)
%         [newI, idxs] = GetQualityPixels(obj, meanLimit, maxLimit)
%         [updI, fgMask] = RemoveBackground(obj, colorLevelsForKMeans, attemptsForKMeans, bigHoleCoefficient, closingCoefficient, openingCoefficient)
%         [c] = GetBandCorrelation(obj, hasPixelSelection)
%         [col] = ToColumn(obj)
%         [obj] = Plus(obj,hsiIm)
%         [obj] = Minus(obj,hsiIm)
%         [obj] = Max(obj, value)
%         [ind] = IsNan(obj)
%         [ind] = IsInf(obj)
%         [obj] = Index(obj, obj2)
%         [obj] = Update(obj, ind, vals)
%         [pHsi] = Preprocessing(obj)
%
        function [m, n, w] = Size(obj)
            [m, n, w] = size(obj.Value);
        end
        
        function [coeff, scores, latent, explained, objective] = Dimred(obj, method, q, mask)
            [coeff, scores, latent, explained, objective] = DimredHSI(obj.Value, method, q, mask);
        end
        
        function [obj] = Normalize(obj, white, black, method)
            obj.Value = NormalizeImage(obj.Value, white, black, method);
        end
        
        function [dispImage] = GetDisplayImage(obj, method, channel)
            dispImage = GetDisplayImage(obj.Value, method, channel);
        end
        
        function [dispImage] = GetDisplayRescaledImage(obj, method, channel)
            dispImage = GetDisplayImage(rescale(obj.Value), method, channel);
        end
        
        function [maskedPixels] = GetPixelsFromMask(obj, mask)
            maskedPixels = GetPixelsFromMask(obj.Value, mask);
        end
        
        function [mask, maskedPixels] = GetMaskFromFigure(obj)
            [mask, maskedPixels] = GetMaskFromFigure(obj.Value);
        end 
        
        function [fgMask] = GetFgMask(obj)
            fgMask = GetFgMask(obj.Value);
        end
        
        function [spectrumCurves] = GetSpectraFromMask(obj, subMasks, targetMask)
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

            hsIm = obj.Value;
            if ndims(hsIm) > 2
                [b, m, n] = size(hsIm);
                hsIm = reshape(hsIm, b, m*n)';
            end

            if hasPixelSelection
                spectralMean = mean(hsIm, 2);
                spectralMax = max(hsIm, [], 2);
                acceptablePixels = spectralMean > 0.2 & spectralMax < 0.99;
                tempI = hsIm(acceptablePixels, :);
            else
                tempI = hsIm;
            end
            c = corr(tempI);
        end
        
        function [col] = ToColumn(obj)
            image = obj.Value;
            col = reshape(image, [size(image, 1) * size(image, 2), size(image, 3)]);
        end
        
        function [obj] = Plus(obj,hsiIm)
            obj.Value = obj.Value + hsiIm;
        end
        
        function [obj] = Minus(obj,hsiIm)
            obj.Value = obj.Value - hsiIm;
        end
        
        function [obj] = Max(obj, value)
            obj.Value = max(obj.Value, value);
        end
        
        function [ind] = IsNan(obj)
            ind = isnan(obj.Value);
        end
        
        function [ind] = IsInf(obj)
            ind = isinf(obj.Value);
        end
        
        function [obj] = Index(obj, obj2)
            hsIm = obj.Value;
            obj.Value = hsIm(obj2.Value);
        end
        
        function [obj] = Update(obj, ind, vals)
            hsIm = obj.Value;
            hsIm(ind) = vals;
            obj.Value = hsIm;
        end
        
        function [pHsi] = Preprocessing(obj)
        % Preprocessing prepares normalized data according to our specifications
        %
        %   Usage:
        %   pHsi = Preprocessing(hsi);
        %
        %   YOU CAN CHANGE THIS FUNCTION ACCORDING TO YOUR SPECIFICATIONS

        hsIm = obj.Value;
        hsIm = hsIm(:, :, [420:730]-380);
        [updI, ~] = hsi.RemoveBackground(hsIm);
        pHsi = updI;

        end
    end
    
end