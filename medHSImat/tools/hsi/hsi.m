classdef hsi
    properties
        Value{mustBeNumeric}
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
        %         [labels] = Cubseg(obj, pixelNum)
        %         [scores] = SPCA(obj, pcNum, labels)
        %
        function [varargout] = Size(obj)
            v{:} = size(obj.Value);
            vals = v{1};
            varargout = cell(numel(vals), 1);
            for i = 1:numel(vals)
                varargout{i} = vals(i);
            end
        end

        function [coeff, scores, latent, explained, objective] = Dimred(obj, varargin)
            %Dimred reduces the dimensions of an image dataset
            %
            %   Input arguments
            %   X: input data as a matrix with MxN observations and Z columns
            %   methods: 'rica', 'pca'
            %   q: number of components to be retained
            %   mask: 2x2 logical array marking pixels to be used in PCA calculation
            %
            %   Usage:
            %   [coeff, scores, latent, explained, objective] = Dimred(X, method, q, mask)
            %   [coeff, scores, latent, explained, ~] = Dimred(X, 'pca', 10)
            %   [coeff, scores, ~, ~, objective] = Dimred(X, 'rica', 40)
            [coeff, scores, latent, explained, objective] = DimredInternal(obj.Value, varargin{:});
        end

        function [obj] = Normalize(obj, varargin)

            %% Normalize a given array I with max and min arrays, white and black
            %  according to methon 'method'
            %
            %   Usage:
            %   normI = NormalizeImage(I, white, black, method)

            obj.Value = NormalizeInternal(obj.Value, varargin{:});
        end

        function [dispImage] = GetDisplayImage(obj, varargin)
            dispImage = GetDisplayImageInternal(obj.Value, varargin{:});
        end

        function [dispImage] = GetDisplayRescaledImage(obj, varargin)
            dispImage = GetDisplayImageInternal(rescale(obj.Value), varargin{:});
        end

        function [maskedPixels] = GetPixelsFromMask(obj, varargin)

            %% GetPixelsFromMask returns flattened pixels according to a 2D mask

            maskedPixels = GetPixelsFromMaskInternal(obj.Value, varargin{:});
        end

        function [mask, maskedPixels] = GetMaskFromFigure(obj)

            %% GetPixelsFromMask returns flattened pixels according to a 2D mask

            [mask, maskedPixels] = GetMaskFromFigureInternal(obj.Value);
        end

        function [fgMask] = GetFgMask(obj)
            %%GetFgMask returns the foreground mask for an image where background
            %%pixels are black
            %
            %   Usage:
            %   fgMask = GetFgMask(hsIm);
            fgMask = GetFgMaskInternal(obj.Value);
        end

        function [spectrumCurves] = GetSpectraFromMask(obj, varargin)
            %%GetSpectraFromMask returns the average spectrum of a specific ROI mask
            %
            %   Usage:
            %   spectrumCurves = GetSpectraFromMask(target, subMasks, targetMask)
            spectrumCurves = GetSpectraFromMaskInternal(obj.Value, varargin{:});
        end

        function [newI, idxs] = GetQualityPixels(obj, varargin)
            %     GETQUALITYPIXELS removes over-saturated and under-exposed pixels from base image
            %
            %     Usage:
            %     [newI, idxs] = GetQualityPixels(I, meanLimit, maxLimit)

            [newI, idxs] = GetQualityPixelsInternal(obj.Value, varargin{:});
        end

        function [updI, fgMask] = RemoveBackground(obj, varargin)
            %     REMOVEBACKGROUND removes the background from the specimen image
            %
            %     Usage:
            %     [updatedHSI, foregroundMask] = RemoveBackground(I)
            %     [updatedHSI, foregroundMask] = RemoveBackground(I, colorLevelsForKMeans,
            %         attemptsForKMeans, bigHoleCoefficient, closingCoefficient, openingCoefficient)
            %     See also https://www.mathworks.com/help/images/color-based-segmentation-using-k-means-clustering.html

            [updI, fgMask] = RemoveBackgroundInternal(obj.Value, varargin{:});
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

        function [obj] = Plus(obj, hsiIm)
            obj.Value = obj.Value + hsiIm;
        end

        function [obj] = Minus(obj, hsiIm)
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

        function [obj] = Preprocessing(obj)
            % Preprocessing prepares normalized data according to our specifications
            %
            %   Usage:
            %   pHsi = Preprocessing(hsi);
            %
            %   YOU CAN CHANGE THIS FUNCTION ACCORDING TO YOUR SPECIFICATIONS

            hsIm = obj.Value;
            hsIm = hsIm(:, :, hsiUtility.GetWavelengths(311, 'index'));
            obj.Value = hsIm;
            [updI, ~] = obj.RemoveBackground();
            obj.Value = updI;
        end

        function [labels] = Cubseg(obj, varargin)
            %%super-pixels segmentation
            labels = cubseg(obj.Value, varargin{:});
        end

        function [scores] = SPCA(obj, varargin)
            %%SupePCA based DR
            scores = SuperPCA(obj.Value, varargin{:});
        end

    end

end