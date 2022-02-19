% ======================================================================
%> @brief hsi is a class that holds the hyperspectral image.
%
%> It is used to contain both the hyperspectral image and additional information.
%> For labels, use @b hsiInfo class.
%>
% ======================================================================
classdef hsi
    properties
        %> A string that shows the target ID
        ID = ''
        %> A string that shows the sampleID
        SampleID = ''
        %> A string that shows the tissue type
        TissueType = ''
        %> The hyperspectral image 
        Value {mustBeNumeric}
        %> The foreground mask i.e. the mask of tissue tensors
        FgMask = []
    end

    methods
        %% Set %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function [obj] = hsi(hsImVal, calcMask, id, sampleId, tissueType)
            if nargin < 2
                calcMask = true;
            end
            
            if nargin < 3 
                obj.ID = id;
            end 
            
            if nargin < 4 
                obj.SampleID = sampleId;
            end
            
            if nargin < 5
                obj.TissueType = tissueType;
            end

            obj.Value = hsImVal;
            if calcMask
                [~, fgMask] = RemoveBackgroundInternal(hsImVal);
                obj.FgMask = fgMask;
            end
            
        end

        function [obj] = set.FgMask(obj, inMask)
            if nargin < 2
                inMask = obj.GetFgMask();
            end
            obj.FgMask = inMask;
        end

        function [obj] = Update(obj, ind, vals)
            hsIm = obj.Value;
            hsIm(ind) = vals;
            obj.Value = hsIm;
        end

        %% Common Properties %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [varargout] = Size(obj)
            v{:} = size(obj.Value);
            vals = v{1};
            varargout = cell(numel(vals), 1);
            for i = 1:numel(vals)
                varargout{i} = vals(i);
            end
        end

        %% Masking %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [maskedPixels] = GetMaskedPixels(obj, mask)
            %%GetMaskedPixels returns flattened pixels according to a 2D mask
            %   If the mask is missing, one is selected based on a manual
            %   polygon selection

            I = obj.Value;
            if nargin < 2
                mask = obj.FgMask;
            else
                % the mask should be limited by the FgMask of the tissue specimen
                mask = mask & obj.FgMask;
            end

            [maskedPixels] = GetMaskedPixelsInternal(I, mask);
        end

        function [fgMask] = GetCustomMask(obj)
            %   GetCustomMask returns a manually drawn polygon mask
            %
            %   Usage:
            %   [fgMask] = GetCustomMask(I);

            fgMask = GetCustomMaskInternal(obj.Value);
            % the mask should be limited by the FgMask of the tissue specimen
            fgMask = fgMask & obj.FgMask;
        end

        function [fgMask] = GetFgMask(obj, varargin)
            %     REMOVEBACKGROUND removes the background from the specimen image
            %
            %     Usage:
            %     [updatedHSI, foregroundMask] = RemoveBackground(I)
            %     [updatedHSI, foregroundMask] = RemoveBackground(I, colorLevelsForKMeans,
            %         attemptsForKMeans, bigHoleCoefficient, closingCoefficient, openingCoefficient)
            %     See also https://www.mathworks.com/help/images/color-based-segmentation-using-k-means-clustering.html

            [~, fgMask] = RemoveBackgroundInternal(obj.Value, varargin{:});
        end

        function [updatedHSI, fgMask] = RemoveBackground(obj, varargin)
            %     REMOVEBACKGROUND removes the background from the specimen image
            %
            %     Usage:
            %     [updatedHSI, foregroundMask] = RemoveBackground(I)
            %     [updatedHSI, foregroundMask] = RemoveBackground(I, colorLevelsForKMeans,
            %         attemptsForKMeans, bigHoleCoefficient, closingCoefficient, openingCoefficient)
            %     See also https://www.mathworks.com/help/images/color-based-segmentation-using-k-means-clustering.html

            [updatedHSI, fgMask] = RemoveBackgroundInternal(obj.Value, varargin{:});
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

        %% Processing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [obj] = Normalize(obj, varargin)
            %%Normalize a given array I with max and min arrays, white and black
            %  according to methon 'method'
            %
            %   Usage:
            %   normI = NormalizeImage(I, white, black, method)

            obj = NormalizeInternal(obj, varargin{:});
        end

        function [obj] = Preprocess(obj, targetName)
            % Preprocessing prepares normalized data according to our specifications
            %
            %   Usage:
            %   pHsi = Preprocessing(hsi,targetName);
            %
            %   YOU CAN CHANGE THIS FUNCTION ACCORDING TO YOUR SPECIFICATIONS

            obj = Preprocessing(obj, targetName);
        end

        %% Segmentation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [labels] = Cubseg(obj, varargin)
            %%super-pixels segmentation
            labels = cubseg(obj.Value, varargin{:});
        end

        %% Dimension Reduction %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function [col] = ToColumn(obj)
            image = obj.Value;
            col = reshape(image, [size(image, 1) * size(image, 2), size(image, 3)]);
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

        function [scores] = SPCA(obj, varargin)
            %%SupePCA based DR
            scores = SuperPCA(obj.Value, varargin{:});
        end

        function [scores] = Transform(obj, method, varargin)
            %Transform applies a transformation like dimension reduction on
            %an hsi image
            [~, scores, ~, ~, ~] = DimredInternal(obj.Value, method, varargin{:});
        end

        %% Visualization %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [dispImage] = GetDisplayImage(obj, varargin)
            dispImage = GetDisplayImageInternal(obj.Value, varargin{:});
        end

        function [dispImage] = GetDisplayRescaledImage(obj, varargin)
            dispImage = GetDisplayImageInternal(rescale(obj.Value), varargin{:});
        end

        %% Metrics %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

        %% Operators %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

    end

    methods (Static)
        
        function [obj] = Read(targetName)
            hsIm = hsi(hsiUtility.LoadHSI(targetName, 'raw'));
        end
        
        %======================================================================
        %> @brief Load recovers the saved instance for the targetID
        %>
        %> In order to work properly it need the argument to be read and preprocessed first.
        %> Use ... 
        %>
        %> @b Usage
        %> 
        %> @code 
        %>  config.SetSetting('normalization', 'raw');
        %>  spectralData = LoadHSIInternal(targetName);
        %>
        %>  spectralData = LoadHSIInternal(targetName, 'dataset');
        %>
        %>  config.SetSetting('normalization', 'byPixel');
        %>  spectralData = LoadHSIInternal(targetName, 'preprocessed');
        %> @endcode
        %>
        %> @param targetID [char] | The unique ID of the target sample
        %> @param dataType [char] | Either 'dataset', 'preprocessed' or 'raw'
        %>
        %> @retval obj [hsi] | The loaded hsi object
        %======================================================================
        function [obj] = Load(targetID, dataType)
        %> @brief Load recovers the saved instance for the targetID
        %>
        %> In order to work properly it need the argument to be read and preprocessed first.
        %> Use ... 
        %>
        %> @b Usage
        %> 
        %> @code 
        %>  config.SetSetting('normalization', 'raw');
        %>  spectralData = LoadHSIInternal(targetName);
        %>
        %>  spectralData = LoadHSIInternal(targetName, 'dataset');
        %>
        %>  config.SetSetting('normalization', 'byPixel');
        %>  spectralData = LoadHSIInternal(targetName, 'preprocessed');
        %> @endcode
        %>
        %> @param targetID [char] | The unique ID of the target sample
        %> @param dataType [char] | Either 'dataset', 'preprocessed' or 'raw'
        %>
        %> @retval obj [hsi] | The loaded hsi object
            if nargin < 2
                dataType = 'raw';
            end

            if isnumeric(targetID)
                targetID = num2str(targetID);
            end
            targetFilename = dataUtility.GetFilename(dataType, targetID);
            
            load(targetFilename, 'spectralData');
            obj = spectralData;
        end        

        function [recHsi] = RecoverSpatialDimensions(redIm, origSize, mask)
            % RecoverOriginalDimensionsInternal returns an image that matches the
            % spatial dimensions of the original hsi
            %
            %   Input arguments:
            %   redIm: reduced dimension data (array or cell of arrays)
            %   origSize: cell array with original sizes of input data (array or cell of arrays)
            %   mask: cell array of masks per data sample (array or cell of arrays)
            %
            %   Returns:
            %   Data with original spatial dimensions and reduced spectral dimensions
            %
            %   Usage:
            %   [recHsi] = RecoverOriginalDimensionsInternal(redIm, origSize, mask)
            %   [redHsis] = RecoverOriginalDimensionsInternal(scores, imgSizes, masks)
            [recHsi] = RecoverOriginalDimensionsInternal(redIm, origSize, mask);
        end

        %% Is %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [flag] = IsHsi(obj)
            %   IsHsi checks if instance object belongs to hsi class

            flag = isequal(class(obj), 'hsi');
        end

    end
end