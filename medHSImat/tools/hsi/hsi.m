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
        Value = []
        %> The foreground mask i.e. the mask of tissue tensors
        FgMask = []
    end

    methods

        %% Set %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % ======================================================================
        %> @brief hsi prepares an instance of class hsi.
        %>
        %> If the values are missing, an empty instance is returned.
        %> In order to work properly, at least the Value property should be set.
        %>
        %> @b Usage
        %>
        %> @code
        %> hsIm = hsi(hsImVal, true, '151', '001', 'unfixed');
        %>
        %> hsIm = hsi(hsImVal, false);
        %> @endcode
        %>
        %> @param hsImVal [numeric array] | A 3D array of the hyperspectral
        %> image data
        %> @param calcMask [boolean] | A flag that enables calculation of
        %> the foreground mask
        %> @param targetId [char] | The unique ID of the target sample
        %> @param sampleID [char] | The sampleID of the target sample
        %> @param tissueType [char] | The tissue type of the target sample
        %>
        %> @return instance of the hsi class
        % ======================================================================
        function [obj] = hsi(hsImVal, calcMask, targetId, sampleId, tissueType)
            % hsi prepares an instance of class hsi.
            %
            % If the values are missing, an empty instance is returned.
            % In order to work properly, at least the Value property should be set.
            %
            % @b Usage
            %
            % @code
            % hsIm = hsi(hsImVal, true, '151', '001', 'unfixed');
            %
            % hsIm = hsi(hsImVal, false);
            % @endcode
            %
            % @param hsImVal [numeric array] | A 3D array of the hyperspectral
            % image data
            % @param calcMask [boolean] | A flag that enables calculation of
            % the foreground mask
            % @param targetId [char] | The unique ID of the target sample
            % @param sampleID [char] | The sampleID of the target sample
            % @param tissueType [char] | The tissue type of the target sample
            %
            % @return instance of the hsi class
            if nargin < 2
                calcMask = true;
            else
                obj.FgMask = [];
            end

            if nargin >= 3
                obj.ID = targetId;
            end

            if nargin >= 4
                obj.SampleID = sampleId;
            end

            if nargin >= 5
                obj.TissueType = tissueType;
            end

            obj.Value = hsImVal;
            if calcMask
                [~, fgMask] = RemoveBackgroundInternal(hsImVal);
                obj.FgMask = fgMask;
            end

        end
        % ======================================================================
        %> @brief set.FgMask sets the FgMask property.
        %>
        %> If the target mask is missing, the property is set by background removal in
        %> @c function RemoveBackgroundInternal.
        %>
        %> @param obj [hsi] | An instance of the hsi class
        %> @param inMask [numeric array] | A foreground mask
        %>
        %> @return instance of the hsi class
        % ======================================================================
        function [obj] = set.FgMask(obj, inMask)
            % set.FgMask sets the FgMask property.
            %
            % If the target mask is missing, the property is set by background removal in
            % @c function RemoveBackgroundInternal.
            %
            % @param obj [hsi] | An instance of the hsi class
            % @param inMask [numeric array] | A foreground mask
            %
            % @return instance of the hsi class
            if nargin < 2
                inMask = obj.GetFgMask();
            end
            obj.FgMask = inMask;
        end

        % ======================================================================
        %> @brief Update updates the Value property.
        %>
        %> The Value values are updated for specific indexes with new values.
        %>
        %> @b Usage
        %>
        %> @code
        %> hsIm = hsIm.Update(hsIm.IsNan(), 0);
        %> @endcode
        %>
        %> @param obj [hsi] | An instance of the hsi class
        %> @param ind [array] | The indexes to be updated
        %> @param vals [array] | The values to be updated
        %>
        %> @return instance of the hsi class
        % ======================================================================
        function [obj] = Update(obj, ind, vals)
            % Update updates the Value property.
            %
            % The Value values are updated for specific indexes with new values.
            %
            % @b Usage
            %
            % @code
            % hsIm = hsIm.Update(hsIm.IsNan(), 0);
            % @endcode
            %
            % @param obj [hsi] | An instance of the hsi class
            % @param ind [array] | The indexes to be updated
            % @param vals [array] | The values to be updated
            %
            % @return instance of the hsi class
            hsIm = obj.Value;
            hsIm(ind) = vals;
            obj.Value = hsIm;
        end

        %% Masking %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % ======================================================================
        %> @brief GetMaskedPixels gets all spectral values included in a mask.
        %>
        %> Pixels are picked up by @c function GetMaskedPixelsInternal.
        %> If the mask is missing, the foreground mask is used.
        %>
        %> @b Usage
        %>
        %> @code
        %> hsIm = hsIm.GetMaskedPixels(mask);
        %> @endcode
        %>
        %> @param obj [hsi] | An instance of the hsi class
        %> @param inMask [numeric array] | Optional: A target mask. Default: The foreground mask
        %> @param isForegroundOnly [boolean] | Optional: Flag to show if foreground mask is applied. Default: true 
        %>
        %> @retval maskedPixels [numeric array] | A 2D array of pixel
        %> spectra aligned vertically. One row is one pixel's spectrum
        % ======================================================================
        function [maskedPixels] = GetMaskedPixels(obj, inMask, isForegroundOnly)
            % GetMaskedPixels gets all spectral values included in a mask.
            %
            % Pixels are picked up by @c function GetMaskedPixelsInternal.
            % If the mask is missing, the foreground mask is used.
            %
            % @b Usage
            %
            % @code
            % hsIm = hsIm.GetMaskedPixels(mask);
            % @endcode
            %
            % @param obj [hsi] | An instance of the hsi class
            % @param inMask [numeric array] | Optional: A target mask. Default: The foreground mask
            % @param isForegroundOnly [boolean] | Optional: Flag to show if foreground mask is applied. Default: true 
            % 
            % foreground mask is applied. Default: true 
            % 
            %
            % @retval maskedPixels [numeric array] | A 2D array of pixel
            % spectra aligned vertically. One row is one pixel's spectrum

            if nargin < 3
                isForegroundOnly = true; 
            end 
            
            I = obj.Value;
            if nargin < 2
                inMask = obj.FgMask;
            else
                % the mask should be limited by the FgMask of the tissue specimen
                if ~isempty(obj.FgMask) && isForegroundOnly
                    inMask = inMask & obj.FgMask;
                end
            end

            [maskedPixels] = GetMaskedPixelsInternal(I, inMask);
        end

        % ======================================================================
        %> @brief GetCustomMask returns a manually drawn polygon mask.
        %>
        %> Pixels are picked up by @c function GetMaskedPixelsInternal.
        %> If the mask is missing, a manually selected mask is assigned by
        %> a polygon selection prompt.
        %>
        %> @b Usage
        %>
        %> @code
        %> hsIm = hsIm.GetCustomMask();
        %> @endcode
        %>
        %> @param obj [hsi] | An instance of the hsi class
        %>
        %> @retval customMask [numeric array] | A custom mask
        % ======================================================================
        function [customMask] = GetCustomMask(obj)
            % GetCustomMask returns a manually drawn polygon mask.
            %
            % Pixels are picked up by @c function GetMaskedPixelsInternal.
            % If the mask is missing, a manually selected mask is assigned by
            % a polygon selection prompt.
            %
            % @b Usage
            %
            % @code
            % hsIm = hsIm.GetCustomMask();
            % @endcode
            %
            % @param obj [hsi] | An instance of the hsi class
            %
            % @retval customMask [numeric array] | A custom mask

            customMask = GetCustomMaskInternal(obj.Value);
        end

        % ======================================================================
        %> @brief GetFgMask returns the foreground mask for a sample.
        %>
        %> The foreground mask corresponds to the tensors that belong to
        %> the tissue. The mask is prepared using @c function
        %> RemoveBackgroundInternal.
        %> See also
        %> https://www.mathworks.com/help/images/color-based-segmentation-using-k-means-clustering.html.
        %>
        %> @b Usage
        %>
        %> @code
        %> hsIm = hsIm.GetFgMask();
        %> @endcode
        %>
        %> @param obj [hsi] | An instance of the hsi class
        %> @param colorLevelsForKMeans [int] | Optional: Color levels for Kmeans. Default is 6.
        %> @param attemptsForKMeans [int] | Optional: Attempts for Kmeans. Default is 3.
        %> @param layerSelectionThreshold [double] | Optional: Threshold for layer
        %> selection. Default is 0.1.
        %> @param bigHoleCoefficient [double] | Optional: Coefficient for closing big
        %> holes. Default is 1000.
        %> @param closingCoefficient [double] | Optional: Coefficient for closing operation. Default is 2.
        %> @param openingCoefficient [double] | Optional: Coefficient for opening operation. Default is 5.
        %>
        %> @retval fgMask [numeric array] | A foreground mask
        % ======================================================================
        function [fgMask] = GetFgMask(obj, varargin)
            % GetFgMask returns the foreground mask for a sample.
            %
            % The foreground mask corresponds to the tensors that belong to
            % the tissue. The mask is prepared using @c function
            % RemoveBackgroundInternal.
            % See also
            % https://www.mathworks.com/help/images/color-based-segmentation-using-k-means-clustering.html.
            %
            % @b Usage
            %
            % @code
            % hsIm = hsIm.GetFgMask();
            % @endcode
            %
            % @param obj [hsi] | An instance of the hsi class
            % @param colorLevelsForKMeans [int] | Optional: Color levels for Kmeans. Default is 6.
            % @param attemptsForKMeans [int] | Optional: Attempts for Kmeans. Default is 3.
            % @param layerSelectionThreshold [double] | Optional: Threshold for layer
            % selection. Default is 0.1.
            % @param bigHoleCoefficient [double] | Optional: Coefficient for closing big
            % holes. Default is 1000.
            % @param closingCoefficient [double] | Optional: Coefficient for closing operation. Default is 2.
            % @param openingCoefficient [double] | Optional: Coefficient for opening operation. Default is 5.
            %
            % @retval fgMask [numeric array] | A foreground mask

            [~, fgMask] = RemoveBackgroundInternal(obj.Value, varargin{:});
        end

        % ======================================================================
        %> @brief GetAverageSpectra returns average spectra for different masks.
        %>
        %> The target masks are set in an 3D array where the last dimension is the mask counter.
        %> If the mask is missing, then the average of the entire image is
        %> calculated. For more details check @c function GetAverageSpectraInternal.
        %>
        %> @b Usage
        %>
        %> @code
        %> averages = hsIm.GetAverageSpectra(subMasks);
        %> @endcode
        %>
        %> @param obj [hsi] | An instance of the hsi class
        %> @param subMasks [numeric array] | Optional: Array of submasks
        %>
        %> @retval averages [numeric array] | A stack of average spectra
        %> for each mask. Each row is the average corresponding to a
        %> submask.
        % ======================================================================
        function [averages] = GetAverageSpectra(obj, varargin)
            % GetAverageSpectra returns average spectra for different masks.
            %
            % The target masks are set in an 3D array where the last dimension is the mask counter.
            % If the mask is missing, then the average of the entire image is
            % calculated. For more details check @c function GetAverageSpectraInternal.
            %
            % @b Usage
            %
            % @code
            % averages = hsIm.GetAverageSpectra(subMasks);
            % @endcode
            %
            % @param obj [hsi] | An instance of the hsi class
            % @param subMasks [numeric array] | Optional: Array of submasks
            %
            % @retval averages [numeric array] | A stack of average spectra
            % for each mask. Each row is the average corresponding to a
            % submask.
            averages = GetAverageSpectraInternal(obj.Value, varargin{:});
        end

        %% Processing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % ======================================================================
        %> @brief Normalize a given hyperspectral image.
        %>
        %> The setting config::'normalization' needs to be set beforehand.
        %> For more details check @c function NormalizeInternal.
        %>
        %> @b Usage
        %>
        %> @code
        %> config.SetSetting('normalization', 'byPixel');
        %> [newI, idxs] = hsIm.Normalize(Iwhite, Iblack, method);
        %> @endcode
        %>
        %> @param obj [hsi] | An instance of the hsi class
        %> @param white [numeric array] | The white reference image
        %> @param black [numeric array] | The black reference image
        %> @param method [string] | The normalization method ('scaling' or 'raw')
        %>
        %> @return instance of the hsi class
        % ======================================================================
        function [obj] = Normalize(obj, varargin)
            % Normalize a given hyperspectral image.
            %
            % The setting config::'normalization' needs to be set beforehand.
            % For more details check @c function NormalizeInternal.
            %
            % @b Usage
            %
            % @code
            % config.SetSetting('normalization', 'byPixel');
            % [newI, idxs] = hsIm.Normalize(Iwhite, Iblack, method);
            % @endcode
            %
            % @param obj [hsi] | An instance of the hsi class
            % @param white [numeric array] | The white reference image
            % @param black [numeric array] | The black reference image
            % @param method [string] | The normalization method ('scaling' or 'raw')
            %
            % @return instance of the hsi class

            obj = NormalizeInternal(obj, varargin{:});
        end

        % ======================================================================
        %> @brief Preprocess data according to specifications.
        %>
        %> The setting config::'normalization' needs to be set beforehand.
        %> For more details check @c function Preprocessing.
        %>
        %> YOU CAN CHANGE THIS FUNCTION ACCORDING TO YOUR SPECIFICATIONS.
        %>
        %> @b Usage
        %>
        %> @code
        %> config.SetSetting('normalization', 'byPixel');
        %> [newI, idxs] = hsIm.Preprocess(targetID);
        %> @endcode
        %>
        %> @param obj [hsi] | An instance of the hsi class
        %> @param targetId [char] | The unique ID of the target sample
        %>
        %> @return instance of the hsi class
        % ======================================================================
        function [obj] = Preprocess(obj, targetID)
            % Preprocess data according to specifications.
            %
            % The setting config::'normalization' needs to be set beforehand.
            % For more details check @c function Preprocessing.
            %
            % YOU CAN CHANGE THIS FUNCTION ACCORDING TO YOUR SPECIFICATIONS.
            %
            % @b Usage
            %
            % @code
            % config.SetSetting('normalization', 'byPixel');
            % [newI, idxs] = hsIm.Preprocess(targetID);
            % @endcode
            %
            % @param obj [hsi] | An instance of the hsi class
            % @param targetId [char] | The unique ID of the target sample
            %
            % @return instance of the hsi class
            obj = Preprocessing(obj, targetID);
        end

        %% Segmentation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % ======================================================================
        %> @brief Cubseg performs segmentation on the hyperspectral image.
        %>
        %> From toolbox SuperPCA [link].
        %>
        %> @b Usage
        %>
        %> @code
        %> labels = hsIm.Cubseg(superixelNumber);
        %> @endcode
        %>
        %> @param obj [hsi] | An instance of the hsi class
        %> @param superixelNumber [int] | The number of superpixels
        %>
        %> @retval labels [numeric array] | The labels for the superpixel
        %> segmentation
        % ======================================================================
        function [labels] = Cubseg(obj, varargin)
            % Cubseg performs segmentation on the hyperspectral image.
            %
            % From toolbox SuperPCA [link].
            %
            % @b Usage
            %
            % @code
            % labels = hsIm.Cubseg(superixelNumber);
            % @endcode
            %
            % @param obj [hsi] | An instance of the hsi class
            % @param superixelNumber [int] | The number of superpixels
            %
            % @retval labels [numeric array] | The labels for the superpixel
            % segmentation
            labels = cubseg(obj.Value, varargin{:});
        end

        % ======================================================================
        %> @brief SPCA performs superPCA.
        %>
        %> From toolbox SuperPCA [link].
        %>
        %> @b Usage
        %>
        %> @code
        %> scores = hsIm.SPCA(superixelNumber);
        %> @endcode
        %>
        %> @param obj [hsi] | An instance of the hsi class
        %> @param components [int] | The number of components
        %> @param label [numeric array] | Superpixel labels
        %>
        %> @retval scores [numeric array] | The transformed values
        % ======================================================================
        function [scores] = SPCA(obj, varargin)
            % SPCA performs superPCA.
            %
            % From toolbox SuperPCA [link].
            %
            % @b Usage
            %
            % @code
            % scores = hsIm.SPCA(superixelNumber);
            % @endcode
            %
            % @param obj [hsi] | An instance of the hsi class
            % @param components [int] | The number of components
            % @param label [numeric array] | Superpixel labels
            %
            % @retval scores [numeric array] | The transformed values
            scores = SuperPCA(obj.Value, varargin{:});
        end

        %% Dimension Reduction %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % ======================================================================
        %> @brief ToColumn reshapes the Value to a column of spectra.
        %>
        %> Reshapes the Value property from 3D to 2D. Each row is one
        %> tensors spectral information.
        %>
        %> @b Usage
        %>
        %> @code
        %> col = hsIm.ToColumn();
        %> @endcode
        %>
        %> @param obj [hsi] | An instance of the hsi class
        %>
        %> @retval col [numeric array] | The reshaped Value spectra
        % ======================================================================
        function [col] = ToColumn(obj)
            % ToColumn reshapes the Value to a column of spectra.
            %
            % Reshapes the Value property from 3D to 2D. Each row is one
            % tensors spectral information.
            %
            % @b Usage
            %
            % @code
            % col = hsIm.ToColumn();
            % @endcode
            %
            % @param obj [hsi] | An instance of the hsi class
            %
            % @retval col [numeric array] | The reshaped Value spectra
            image = obj.Value;
            col = reshape(image, [size(image, 1) * size(image, 2), size(image, 3)]);
        end

        % ======================================================================
        %> @brief Dimred reduces the dimensions of the hyperspectral image.
        %>
        %> Currently PCA, RICA, SuperPCA, LDA, QDA are available. For more
        %> details check @c function Dimred.
        %>
        %> @b Usage
        %>
        %> @code
        %> q = 10;
        %> [coeff, scores, latent, explained, objective] = hsIm.Dimred(
        %> method, q, hsIm.FgMask);
        %>
        %> [coeff, scores, latent, explained, ~] = hsIm.Dimred('pca', 10);
        %>
        %> [coeff, scores, ~, ~, objective] = hsIm.Dimred('rica', 40);
        %> @endcode
        %>
        %> @param obj [hsi] | An instance of the hsi class
        %> @param method [string] | The method for dimension reduction
        %> @param q [int] | The number of components to be retained
        %> @param mask [numerical array] | A 2x2 logical array marking pixels to be used in PCA calculation
        %>
        %> @retval coeff [numeric array] | The transformation coefficients
        %> @retval scores [numeric array] | The transformed values
        %> @retval latent [numeric array] | The latent values
        %> @retval explained [numeric array] | The percentage of explained
        %> variance
        %> @retval objective [numeric array] | The objective function
        %> values
        %> @retval Mdl [model] | The dimension reduction model
        % ======================================================================
        function [coeff, scores, latent, explained, objective] = Dimred(obj, varargin)
            % Dimred reduces the dimensions of the hyperspectral image.
            %
            % Currently PCA, RICA, SuperPCA, LDA, QDA are available. For more
            % details check @c function Dimred.
            %
            % @b Usage
            %
            % @code
            % q = 10;
            % [coeff, scores, latent, explained, objective] = hsIm.Dimred(
            % method, q, hsIm.FgMask);
            %
            % [coeff, scores, latent, explained, ~] = hsIm.Dimred('pca', 10);
            %
            % [coeff, scores, ~, ~, objective] = hsIm.Dimred('rica', 40);
            % @endcode
            %
            % @param obj [hsi] | An instance of the hsi class
            % @param method [string] | The method for dimension reduction
            % @param q [int] | The number of components to be retained
            % @param mask [numerical array] | A 2x2 logical array marking pixels to be used in PCA calculation
            %
            % @retval coeff [numeric array] | The transformation coefficients
            % @retval scores [numeric array] | The transformed values
            % @retval latent [numeric array] | The latent values
            % @retval explained [numeric array] | The percentage of explained
            % variance
            % @retval objective [numeric array] | The objective function
            % values
            % @retval Mdl [model] | The dimension reduction model
            [coeff, scores, latent, explained, objective] = DimredInternal(obj.Value, varargin{:});
        end

        % ======================================================================
        %> @brief Transform applies a transform to the hyperspectral data.
        %>
        %> Currently PCA, RICA, SuperPCA, LDA, QDA are available. For more
        %> details check @c function Dimred.
        %>
        %> @b Usage
        %>
        %> @code
        %> scores = hsIm.Transform(superixelNumber);
        %> @endcode
        %>
        %> @param obj [hsi] | An instance of the hsi class
        %> @param method [string] | The method for dimension reduction
        %> @param q [int] | The number of components to be retained
        %> @param mask [numerical array] | A 2x2 logical array marking pixels to be used in PCA calculation
        %>
        %> @retval scores [numeric array] | The transformed values
        % ======================================================================
        function [scores] = Transform(obj, method, varargin)
            % Transform applies a transform to the hyperspectral data.
            %
            % Currently PCA, RICA, SuperPCA, LDA, QDA are available. For more
            % details check @c function Dimred.
            %
            % @b Usage
            %
            % @code
            % scores = hsIm.Transform(superixelNumber);
            % @endcode
            %
            % @param obj [hsi] | An instance of the hsi class
            % @param method [string] | The method for dimension reduction
            % @param q [int] | The number of components to be retained
            % @param mask [numerical array] | A 2x2 logical array marking pixels to be used in PCA calculation
            %
            % @retval scores [numeric array] | The transformed values
            [~, scores, ~, ~, ~] = DimredInternal(obj.Value, method, varargin{:});
        end

        %% Visualization %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % ======================================================================
        %> @brief GetDisplayImage returns an RGB image from the hyperspectral data.
        %>
        %> For more details check @c function GetDisplayImageInternal.
        %> @b Usage
        %>
        %> @code
        %> dispImage = hsIm.GetDisplayImage(superixelNumber);
        %>
        %> dispImage = hsIm.GetDisplayImage('rgb');
        %>
        %> dispImage = hsIm.GetDisplayImage('channel', 200);
        %> @endcode
        %>
        %> @param obj [hsi] | An instance of the hsi class
        %> @param method [string] | The method for display image creation
        %> ('rgb' or 'channel')
        %> @param channelNumber [int] | The target channel number
        %>
        %> @retval dispImage [numeric array] | The display image
        % ======================================================================
        function [dispImage] = GetDisplayImage(obj, varargin)
            % GetDisplayImage returns an RGB image from the hyperspectral data.
            %
            % For more details check @c function GetDisplayImageInternal.
            % @b Usage
            %
            % @code
            % dispImage = hsIm.GetDisplayImage(superixelNumber);
            %
            % dispImage = hsIm.GetDisplayImage('rgb');
            %
            % dispImage = hsIm.GetDisplayImage('channel', 200);
            % @endcode
            %
            % @param obj [hsi] | An instance of the hsi class
            % @param method [string] | The method for display image creation
            % ('rgb' or 'channel')
            % @param channelNumber [int] | The target channel number
            %
            % @retval dispImage [numeric array] | The display image
            dispImage = GetDisplayImageInternal(obj.Value, varargin{:});
        end

        % ======================================================================
        %> @brief GetDisplayRescaledImage returns an rescaled RGB image from the hyperspectral data.
        %>
        %> For more details check @c function GetDisplayImageInternal.
        %>
        %> @b Usage
        %>
        %> @code
        %> dispImage = hsIm.GetDisplayRescaledImage(superixelNumber);
        %>
        %> dispImage = hsIm.GetDisplayRescaledImage('rgb');
        %>
        %> dispImage = hsIm.GetDisplayRescaledImage('channel', 200);
        %> @endcode
        %>
        %> @param obj [hsi] | An instance of the hsi class
        %> @param method [string] | The method for display image creation
        %> ('rgb' or 'channel')
        %> @param channelNumber [int] | The target channel number
        %>
        %> @retval dispImage [numeric array] | The display image
        % ======================================================================
        function [dispImage] = GetDisplayRescaledImage(obj, varargin)
            % GetDisplayRescaledImage returns an rescaled RGB image from the hyperspectral data.
            %
            % For more details check @c function GetDisplayImageInternal.
            %
            % @b Usage
            %
            % @code
            % dispImage = hsIm.GetDisplayRescaledImage(superixelNumber);
            %
            % dispImage = hsIm.GetDisplayRescaledImage('rgb');
            %
            % dispImage = hsIm.GetDisplayRescaledImage('channel', 200);
            % @endcode
            %
            % @param obj [hsi] | An instance of the hsi class
            % @param method [string] | The method for display image creation
            % ('rgb' or 'channel')
            % @param channelNumber [int] | The target channel number
            %
            % @retval dispImage [numeric array] | The display image
            dispImage = GetDisplayImageInternal(rescale(obj.Value), varargin{:});
        end

        % ======================================================================
        %> @brief SubimageMontage plots a montage of the subimages of a hyperspectral image.
        %>
        %> @b Usage
        %>
        %> @code
        %> hsIm.SubimageMontage(1);
        %> @endcode
        %>
        %> @param obj [hsi] | An instance of the hsi class
        %> @param fig [int] | The figure handle
        % ======================================================================
        function [] = SubimageMontage(obj, fig)
            % SubimageMontage plots a montage of the subimages of a hyperspectral image.
            %
            % @b Usage
            %
            % @code
            % hsIm.SubimageMontage(1);
            % @endcode
            %
            % @param obj [hsi] | An instance of the hsi class
            % @param fig [int] | The figure handle
            fig = figure(fig);
            clf(fig);
            [~, ~, z] = size(obj.Value);
            vals = floor(linspace(1, z, 10));
            w = hsiUtility.GetWavelengths(z);

            tlo = tiledlayout(fig, 2, 5, 'TileSpacing', 'None');
            for i = 1:numel(vals)
                ax = nexttile(tlo);
                img = squeeze(obj.Value(:, :, vals(i)));
                imshow(img, 'Parent', ax);
                wavelength = w(vals(i));
                title([num2str(wavelength), 'nm'])
            end

            plots.SavePlot(fig);
        end

        %% Metrics %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % ======================================================================
        %> @brief GetBandCorrelation returns pixel correlations at each spectral band.
        %>
        %> @b Usage
        %>
        %> @code
        %> [c] = hsIm.GetBandCorrelation();
        %>
        %> [c] = hsIm.GetBandCorrelation(hasPixelSelection);
        %> @endcode
        %>
        %> @param obj [hsi] | An instance of the hsi class
        %> @param hasPixelSelection [boolean] | A flag for pixel selection
        %>
        %> @retval c [numeric array] | The correlation array
        % ======================================================================
        function [c] = GetBandCorrelation(obj, hasPixelSelection)
            % GetBandCorrelation returns pixel correlations at each spectral band.
            %
            % @b Usage
            %
            % @code
            % [c] = hsIm.GetBandCorrelation();
            %
            % [c] = hsIm.GetBandCorrelation(hasPixelSelection);
            % @endcode
            %
            % @param obj [hsi] | An instance of the hsi class
            % @param hasPixelSelection [boolean] | A flag for pixel selection
            %
            % @retval c [numeric array] | The correlation array
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
        % ======================================================================
        %> @brief Plus adds a value to Value property
        %>
        %> @b Usage
        %>
        %> @code
        %> hsIm = hsIm.Plus(vals);
        %> @endcode
        %>
        %> @param obj [hsi] | An instance of the hsi class
        %> @param hsiIm [numerical array] | Values to be added
        %>
        %> @return instance of the hsi class
        % ======================================================================
        function [obj] = Plus(obj, hsiIm)
            % Plus adds a value to Value property
            %
            % @b Usage
            %
            % @code
            % hsIm = hsIm.Plus(vals);
            % @endcode
            %
            % @param obj [hsi] | An instance of the hsi class
            % @param hsiIm [numerical array] | Values to be added
            %
            % @return instance of the hsi class
            obj.Value = obj.Value + hsiIm;
        end

        % ======================================================================
        %> @brief Minus subracts values from Value property
        %>
        %> @b Usage
        %>
        %> @code
        %> hsIm = hsIm.Minus(vals);
        %> @endcode
        %>
        %> @param obj [hsi] | An instance of the hsi class
        %> @param hsiIm [numerical array] | Values to be subtracted
        %>
        %> @return instance of the hsi class
        % ======================================================================
        function [obj] = Minus(obj, hsiIm)
            % Minus subracts values from Value property
            %
            % @b Usage
            %
            % @code
            % hsIm = hsIm.Minus(vals);
            % @endcode
            %
            % @param obj [hsi] | An instance of the hsi class
            % @param hsiIm [numerical array] | Values to be subtracted
            %
            % @return instance of the hsi class
            obj.Value = obj.Value - hsiIm;
        end

        % ======================================================================
        %> @brief Max calculates the max between a value array and a Value property
        %>
        %> @b Usage
        %>
        %> @code
        %> hsIm = hsIm.Max(vals);
        %> @endcode
        %>
        %> @param obj [hsi] | An instance of the hsi class
        %> @param hsiIm [numerical array] | Values to be compared
        %>
        %> @return instance of the hsi class
        % ======================================================================
        function [obj] = Max(obj, value)
            % Max calculates the max between a value array and a Value property
            %
            % @b Usage
            %
            % @code
            % hsIm = hsIm.Max(vals);
            % @endcode
            %
            % @param obj [hsi] | An instance of the hsi class
            % @param hsiIm [numerical array] | Values to be compared
            %
            % @return instance of the hsi class
            obj.Value = max(obj.Value, value);
        end

        % ======================================================================
        %> @brief IsNan calculates nan indexes of a Value property
        %>
        %> @b Usage
        %>
        %> @code
        %> hsIm = hsIm.IsNan(vals);
        %> @endcode
        %>
        %> @param obj [hsi] | An instance of the hsi class
        %>
        %> @retval ind [numeric array] | The indexes of nan values
        % ======================================================================
        function [ind] = IsNan(obj)
            % IsNan calculates nan indexes of a Value property
            %
            % @b Usage
            %
            % @code
            % hsIm = hsIm.IsNan(vals);
            % @endcode
            %
            % @param obj [hsi] | An instance of the hsi class
            %
            % @retval ind [numeric array] | The indexes of nan values
            ind = isnan(obj.Value);
        end

        % ======================================================================
        %> @brief IsInf calculates infinite indexes of a Value property
        %>
        %> @b Usage
        %>
        %> @code
        %> hsIm = hsIm.IsInf(vals);
        %> @endcode
        %>
        %> @param obj [hsi] | An instance of the hsi class
        %>
        %> @retval ind [numeric array] | The indexes of infinite values
        % ======================================================================
        function [ind] = IsInf(obj)
            % IsInf calculates infinite indexes of a Value property
            %
            % @b Usage
            %
            % @code
            % hsIm = hsIm.IsInf(vals);
            % @endcode
            %
            % @param obj [hsi] | An instance of the hsi class
            %
            % @retval ind [numeric array] | The indexes of infinite values
            ind = isinf(obj.Value);
        end

    end

    methods (Static)

        %======================================================================
        %> @brief Load recovers the saved instance for the targetID
        %>
        %> In order to work properly it need the argument to be read and preprocessed first.
        %> Use @c function hsiUtility.PrepareDataset for initialization.
        %>
        %> @b Usage
        %>
        %> @code
        %>  config.SetSetting('normalization', 'raw');
        %>  spectralData = hsi.Load(targetName);
        %>
        %>  spectralData = hsi.Load(targetName, 'dataset');
        %>
        %>  config.SetSetting('normalization', 'byPixel');
        %>  spectralData = hsi.Load(targetName, 'preprocessed');
        %> @endcode
        %>
        %> @param targetID [char] | The unique ID of the target sample
        %> @param dataType [char] | Either 'dataset', 'preprocessed' or 'raw'
        %>
        %> @retval obj [hsi] | The loaded hsi object
        %======================================================================
        function [obj] = Load(targetID, dataType)
            % Load recovers the saved instance for the targetID
            %
            % In order to work properly it need the argument to be read and preprocessed first.
            % Use @c function hsiUtility.PrepareDataset for initialization.
            %
            % @b Usage
            %
            % @code
            %  config.SetSetting('normalization', 'raw');
            %  spectralData = hsi.Load(targetName);
            %
            %  spectralData = hsi.Load(targetName, 'dataset');
            %
            %  config.SetSetting('normalization', 'byPixel');
            %  spectralData = hsi.Load(targetName, 'preprocessed');
            % @endcode
            %
            % @param targetID [char] | The unique ID of the target sample
            % @param dataType [char] | Either 'dataset', 'preprocessed' or 'raw'
            %
            % @retval obj [hsi] | The loaded hsi object
            if nargin < 2
                dataType = 'raw';
            end

            if isnumeric(targetID)
                targetID = num2str(targetID);
            end
            targetFilename = commonUtility.GetFilename(dataType, targetID);

            if strcmp(dataType, 'raw')
                fprintf('Loads raw HSI.\n');
            else
                fprintf('Loads from dataset %s with normalization %s.\n', config.GetSetting('dataset'), config.GetSetting('normalization'));
            end
            if exist(targetFilename, 'file')
                fprintf('Filename: %s.\n', targetFilename);
                load(targetFilename, 'spectralData');
                obj = spectralData;
            else
                error('The filename %s does not exist.\n', targetFilename);
            end
        end

        %======================================================================
        %> @brief RecoverSpatialDimensions recovers the original spatial dimension
        %> from masked pixels.
        %>
        %> Data with original spatial dimensions and reduced spectral dimensions
        %> For more details check @c function RecoverOriginalDimensionsInternal.
        %>
        %> @b Usage
        %>
        %> @code
        %> [recHsi] = hsi.RecoverOriginalDimensionsInternal(redIm, origSize, mask);
        %>
        %> [recHsi] = hsi.RecoverOriginalDimensionsInternal(scores, imgSizes, masks);
        %> @endcode
        %>
        %> @param obj [hsi] | An hsi instance
        %> @param origSize [cell array] | Original sizes of input data (array or cell of arrays)
        %> @param mask [cell array] | Optional: Masks per data sample (array or cell of arrays)
        %>
        %> @retval obj [hsi] | The reconstructed hsi instance
        %======================================================================
        function [recHsi] = RecoverSpatialDimensions(varargin)
            % RecoverSpatialDimensions recovers the original spatial dimension
            % from masked pixels.
            %
            % Data with original spatial dimensions and reduced spectral dimensions
            % For more details check @c function RecoverOriginalDimensionsInternal.
            %
            % @b Usage
            %
            % @code
            % [recHsi] = hsi.RecoverOriginalDimensionsInternal(redIm, origSize, mask);
            %
            % [recHsi] = hsi.RecoverOriginalDimensionsInternal(scores, imgSizes, masks);
            % @endcode
            %
            % @param obj [hsi] | An hsi instance
            % @param origSize [cell array] | Original sizes of input data (array or cell of arrays)
            % @param mask [cell array] | Optional: Masks per data sample (array or cell of arrays)
            %
            % @retval obj [hsi] | The reconstructed hsi instance
            [recHsi] = RecoverOriginalDimensionsInternal(varargin{:});
        end

        %======================================================================
        %> @brief IsHsi checks if a variable is of an hsi instance
        %>
        %> @b Usage
        %>
        %> @code
        %> flag = hsi.IsHsi(redIm);
        %> @endcode
        %>
        %> @param obj [any] | A variable
        %>
        %> @retval flag [boolean] | The flag
        %======================================================================
        function [flag] = IsHsi(obj)
            % IsHsi checks if a variable is of an hsi instance
            %
            % @b Usage
            %
            % @code
            % flag = hsi.IsHsi(redIm);
            % @endcode
            %
            % @param obj [any] | A variable
            %
            % @retval flag [boolean] | The flag

            flag = isequal(class(obj), 'hsi');
        end

    end
end