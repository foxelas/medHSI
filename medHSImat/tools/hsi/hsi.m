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
                disp('Calculating foreground mask.')
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

            if nargin < 2
                inMask = obj.GetFgMask();
            end
            obj.FgMask = inMask;
        end

        % ======================================================================
        %> @brief hsi.Update updates the Value property.
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
            % ======================================================================
            %> @brief hsi.Update updates the Value property.
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

            hsIm = obj.Value;
            hsIm(ind) = vals;
            obj.Value = hsIm;
        end

        %% Masking %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % ======================================================================
        %> @brief hsi.GetMaskedPixels gets all spectral values included in a mask.
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
            % ======================================================================
            %> @brief hsi.GetMaskedPixels gets all spectral values included in a mask.
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
        %> @brief hsi.GetCustomMask returns a manually drawn polygon mask.
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
            % ======================================================================
            %> @brief hsi.GetCustomMask returns a manually drawn polygon mask.
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

            customMask = GetCustomMaskInternal(obj.Value);
        end

        % ======================================================================
        %> @brief hsi.GetFgMask returns the foreground mask for a sample.
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
            % ======================================================================
            %> @brief hsi.GetFgMask returns the foreground mask for a sample.
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

            [~, fgMask] = RemoveBackgroundInternal(obj.Value, varargin{:});
        end

        % ======================================================================
        %> @brief hsi.GetAverageSpectra returns average spectra for different masks.
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
            % ======================================================================
            %> @brief hsi.GetAverageSpectra returns average spectra for different masks.
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

            averages = GetAverageSpectraInternal(obj.Value, varargin{:});
        end

        %% Processing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % ======================================================================
        %> @brief hsi.Normalize a given hyperspectral image.
        %>
        %> The setting config::[Normalization] needs to be set beforehand.
        %> For more details check @c function NormalizeInternal.
        %>
        %> @b Usage
        %>
        %> @code
        %> config.SetSetting('Normalization', 'byPixel');
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
            % ======================================================================
            %> @brief hsi.Normalize a given hyperspectral image.
            %>
            %> The setting config::[Normalization] needs to be set beforehand.
            %> For more details check @c function NormalizeInternal.
            %>
            %> @b Usage
            %>
            %> @code
            %> config.SetSetting('Normalization', 'byPixel');
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

            obj = NormalizeInternal(obj, varargin{:});
        end

        % ======================================================================
        %> @brief hsi.Preprocess data according to specifications.
        %>
        %> The setting config::[Normalization] needs to be set beforehand.
        %> For more details check @c function Preprocessing.
        %>
        %> YOU CAN CHANGE THIS FUNCTION ACCORDING TO YOUR SPECIFICATIONS.
        %>
        %> @b Usage
        %>
        %> @code
        %> config.SetSetting('Normalization', 'byPixel');
        %> [newI, idxs] = hsIm.Preprocess(targetID);
        %> @endcode
        %>
        %> @param obj [hsi] | An instance of the hsi class
        %> @param targetId [char] | The unique ID of the target sample
        %>
        %> @return instance of the hsi class
        % ======================================================================
        function [obj] = Preprocess(obj, targetID)
            % ======================================================================
            %> @brief hsi.Preprocess data according to specifications.
            %>
            %> The setting config::[Normalization] needs to be set beforehand.
            %> For more details check @c function Preprocessing.
            %>
            %> YOU CAN CHANGE THIS FUNCTION ACCORDING TO YOUR SPECIFICATIONS.
            %>
            %> @b Usage
            %>
            %> @code
            %> config.SetSetting('Normalization', 'byPixel');
            %> [newI, idxs] = hsIm.Preprocess(targetID);
            %> @endcode
            %>
            %> @param obj [hsi] | An instance of the hsi class
            %> @param targetId [char] | The unique ID of the target sample
            %>
            %> @return instance of the hsi class
            % ======================================================================

            obj = Preprocessing(obj, targetID);
        end

        %% Dimension Reduction %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % ======================================================================
        %> @brief hsi.ToColumn reshapes the Value to a column of spectra.
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
            % ======================================================================
            %> @brief hsi.ToColumn reshapes the Value to a column of spectra.
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

            image = obj.Value;
            col = reshape(image, [size(image, 1) * size(image, 2), size(image, 3)]);
        end

        % ======================================================================
        %> @brief hsi.DistanceScores returns similarity clustering labels for a target hsi based on a references set of spectral curves.
        %>
        %> You can set the spectral distance metric with funcHandle.
        %> Common spectral ditance metrics are @@sam, sid, @jmsam, @ns3, @sidsam.
        %> For more details check @c DistanceScoresInternal.
        %>
        %> @b Usage
        %>
        %> @code
        %> clusterLabels = hsIm.DistanceScores(target, endmembers, @sam);
        %> @endcode
        %>
        %> @param target [numeric array] | An 3D hsi value
        %> @param references [numeric array] | An array of spectral references
        %> @param funcHandle [function handle] | Optional: The spectral distance measure. Default: SAM.
        %>
        %> @retval clusterLabels [numeric array] | The labels based on minimum distance.
        % ======================================================================
        function [clusterLabels] = DistanceScores(obj, varargin)
            % ======================================================================
            %> @brief hsi.DistanceScores returns similarity clustering labels for a target hsi based on a references set of spectral curves.
            %>
            %> You can set the spectral distance metric with funcHandle.
            %> Common spectral ditance metrics are @@sam, sid, @jmsam, @ns3, @sidsam.
            %> For more details check @c DistanceScoresInternal.
            %>
            %> @b Usage
            %>
            %> @code
            %> clusterLabels = hsIm.DistanceScores(target, endmembers, @sam);
            %> @endcode
            %>
            %> @param target [numeric array] | An 3D hsi value
            %> @param references [numeric array] | An array of spectral references
            %> @param funcHandle [function handle] | Optional: The spectral distance measure. Default: SAM.
            %>
            %> @retval clusterLabels [numeric array] | The labels based on minimum distance.
            % ======================================================================

            [clusterLabels] = DistanceScoresInternal(obj.Value, varargin{:});
        end

        % ======================================================================
        %> @brief hsi.Dimred reduces the dimensions of the hyperspectral image.
        %>
        %> Currently available methods:
        %> PCA, SuperPCA, MSuperPCA, ClusterPCA, MClusterPCA,
        %> ICA (FastICA), RICA, SuperRICA,
        %> LDA, QDA, MSelect.
        %> Methods autoencoder and RFI are available only for pre-trained models.
        %>
        %> Additionally, for pre-trained parameters RFI and Autoencoder are available.
        %> For an unknown method, the input data is returned.
        %>
        %> For more details check @c dimredUtility.Apply .
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
        %> @param varargin [cell array] | Optional additional arguments for methods that require them
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
        function [coeff, scores, latent, explained, objective, Mdl] = Dimred(obj, method, q, varargin)
            % ======================================================================
            %> @brief hsi.Dimred reduces the dimensions of the hyperspectral image.
            %>
            %> Currently available methods:
            %> PCA, SuperPCA, MSuperPCA, ClusterPCA, MClusterPCA,
            %> ICA (FastICA), RICA, SuperRICA,
            %> LDA, QDA, MSelect.
            %> Methods autoencoder and RFI are available only for pre-trained models.
            %>
            %> Additionally, for pre-trained parameters RFI and Autoencoder are available.
            %> For an unknown method, the input data is returned.
            %>
            %> For more details check @c dimredUtility.Apply .
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
            %> @param varargin [cell array] | Optional additional arguments for methods that require them
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
            [coeff, scores, latent, explained, objective, Mdl] = dimredUtility.Apply(obj.Value, method, q, obj.FgMask, varargin{:});
        end

        % ======================================================================
        %> @brief hsi.Transform applies a transform to the hyperspectral data.
        %>
        %> Currently available methods:
        %> PCA, SuperPCA, MSuperPCA, ClusterSuperPCA,
        %> ICA (FastICA), RICA, SuperRICA,
        %> LDA, QDA, MSelect.
        %> Methods autoencoder and RFI are available only for pre-trained models.
        %>
        %> Additionally, for pre-trained parameters RFI and Autoencoder are available.
        %> For an unknown method, the input data is returned.
        %> For more details check @c function dimredUtility.Apply.
        %>
        %> @b Usage
        %>
        %> @code
        %> scores = hsIm.Dim(superixelNumber);
        %> @endcode
        %>
        %> @param obj [hsi] | An instance of the hsi class
        %> @param flattenFlag [boolean] | The flag for flattening. Default: true.
        %> @param method [string] | The method for dimension reduction
        %> @param q [int] | The number of components to be retained
        %> @param varargin [cell array] | Optional additional arguments for methods that require them
        %>
        %> @retval scores [numeric array] | The transformed values
        % ======================================================================
        function [scores] = Transform(obj, flattenFlag, method, q, varargin)
            % ======================================================================
            %> @brief hsi.Transform applies a transform to the hyperspectral data.
            %>
            %> Currently available methods:
            %> PCA, SuperPCA, MSuperPCA, ClusterSuperPCA,
            %> ICA (FastICA), RICA, SuperRICA,
            %> LDA, QDA, MSelect.
            %> Methods autoencoder and RFI are available only for pre-trained models.
            %>
            %> Additionally, for pre-trained parameters RFI and Autoencoder are available.
            %> For an unknown method, the input data is returned.
            %> For more details check @c function dimredUtility.Apply.
            %>
            %> @b Usage
            %>
            %> @code
            %> scores = hsIm.Transform(superixelNumber);
            %> @endcode
            %>
            %> @param obj [hsi] | An instance of the hsi class
            %> @param flattenFlag [boolean] | The flag for flattening. Default: true.
            %> @param method [string] | The method for dimension reduction
            %> @param q [int] | The number of components to be retained
            %> @param varargin [cell array] | Optional additional arguments for methods that require them
            %>
            %> @retval scores [numeric array] | The transformed values
            % ======================================================================

            [~, scores, ~, ~, ~] = obj.Dimred(method, q, varargin{:});

            if isempty(flattenFlag)
                flattenFlag = true;
            end
            if flattenFlag
                scores = GetMaskedPixelsInternal(scores, obj.FgMask);
            end
        end

        % ======================================================================
        %> @brief hsi.FindPurePixels applies the algorithm on an hsi object.
        %>
        %> When a foreground mask is provided, then pure pixels are calculated using only the specimen pixels of the hsi, while ignoring the bakcground.
        %> For more details see @c FindPurePuxelsInternal.
        %>
        %> @b Usage
        %>
        %> @code
        %> [endmembers] = hsIm.FindPurePixels(8, 'nfindr', reductionMethod);
        %>
        %> [endmembers] = FindPurePixelsInternal(hsIm.Value, 8, hsIm.FgMask, 'nfindr', reductionMethod);
        %> @endcode
        %>
        %> @param target [numeric array] | An 3d array of the hsi value
        %> @param numEndmembers [int] | The number of endmembers to calculate
        %> @param fgMask [numeric array] | The foregound mask
        %> @param method [char] | Optional: The method to find pure pixels. Options: ['NFindr', 'ppi', 'fippi']. Default: 'NFindr'.
        %> @param reductionMethod [char] | Optional: The reduction method. Options: ['PCA', 'MNF']. Default: 'MNF'.
        %>
        %> @retval endmembers [numeric array] |The calculated endmembers.
        % ======================================================================
        function [endmembers] = FindPurePixels(obj, numEndmembers, varargin)
            % ======================================================================
            %> @brief hsi.FindPurePixels applies the algorithm on an hsi object.
            %>
            %> When a foreground mask is provided, then pure pixels are calculated using only the specimen pixels of the hsi, while ignoring the bakcground.
            %> For more details see @c FindPurePuxelsInternal.
            %>
            %> @b Usage
            %>
            %> @code
            %> [endmembers] = hsIm.FindPurePixels(8, 'nfindr', reductionMethod);
            %>
            %> [endmembers] = FindPurePixelsInternal(hsIm.Value, 8, hsIm.FgMask, 'nfindr', reductionMethod);
            %> @endcode
            %>
            %> @param target [numeric array] | An 3d array of the hsi value
            %> @param numEndmembers [int] | The number of endmembers to calculate
            %> @param fgMask [numeric array] | The foregound mask
            %> @param method [char] | Optional: The method to find pure pixels. Options: ['NFindr', 'ppi', 'fippi']. Default: 'NFindr'.
            %> @param reductionMethod [char] | Optional: The reduction method. Options: ['PCA', 'MNF']. Default: 'MNF'.
            %>
            %> @retval endmembers [numeric array] |The calculated endmembers.
            % ======================================================================
            [endmembers] = FindPurePixelsInternal(obj.Value, numEndmembers, obj.FgMask, varargin{:});
        end

        %% Visualization %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % ======================================================================
        %> @brief hsi.GetDisplayImage returns an RGB image from the hyperspectral data.
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
            % ======================================================================
            %> @brief hsi.GetDisplayImage returns an RGB image from the hyperspectral data.
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

            dispImage = GetDisplayImageInternal(obj.Value, varargin{:});
        end

        % ======================================================================
        %> @brief hsi.GetDisplayRescaledImage returns an rescaled RGB image from the hyperspectral data.
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
            % ======================================================================
            %> @brief hsi.GetDisplayRescaledImage returns an rescaled RGB image from the hyperspectral data.
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

            dispImage = GetDisplayImageInternal(rescale(obj.Value), varargin{:});
        end

        % ======================================================================
        %> @brief hsi.SubimageMontage plots a montage of the subimages of a hyperspectral image.
        %>
        %> @b Usage
        %>
        %> @code
        %> hsIm.SubimageMontage(1);
        %> @endcode
        %>
        %> @param obj [hsi] | An instance of the hsi class
        %> @param fig [int] | The figure handle
        %> @param plotPath [char] | The path to save the figure plot
        % ======================================================================
        function [] = SubimageMontage(obj, fig, plotPath)
            % ======================================================================
            %> @brief hsi.SubimageMontage plots a montage of the subimages of a hyperspectral image.
            %>
            %> @b Usage
            %>
            %> @code
            %> hsIm.SubimageMontage(1);
            %> @endcode
            %>
            %> @param obj [hsi] | An instance of the hsi class
            %> @param fig [int] | The figure handle
            %> @param plotPath [char] | The path to save the figure plot
            % ======================================================================
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

            plots.SavePlot(fig, plotPath);
        end

        %% Metrics %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % ======================================================================
        %> @brief hsi.GetBandCorrelation returns pixel correlations at each spectral band.
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
            % ======================================================================
            %> @brief hsi.GetBandCorrelation returns pixel correlations at each spectral band.
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
        %> @brief hsi.Plus adds a value to Value property
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
            % ======================================================================
            %> @brief hsi.Plus adds a value to Value property
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
            obj.Value = obj.Value + hsiIm;
        end

        % ======================================================================
        %> @brief hsi.Minus subracts values from Value property
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
            % ======================================================================
            %> @brief hsi.Minus subracts values from Value property
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
            obj.Value = obj.Value - hsiIm;
        end

        % ======================================================================
        %> @brief hsi.Max calculates the max between a value array and a Value property
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
            % ======================================================================
            %> @brief hsi.Max calculates the max between a value array and a Value property
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
            obj.Value = max(obj.Value, value);
        end

        % ======================================================================
        %> @brief hsi.IsNan calculates nan indexes of a Value property
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
            % ======================================================================
            %> @brief hsi.IsNan calculates nan indexes of a Value property
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
            ind = isnan(obj.Value);
        end

        % ======================================================================
        %> @brief hsi.IsInf calculates infinite indexes of a Value property
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
            % ======================================================================
            %> @brief hsi.IsInf calculates infinite indexes of a Value property
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
            ind = isinf(obj.Value);
        end

        %======================================================================
        %> @brief hsi.SAMscore returns SAM silimarity scores compared to a healthy tissue signature in degrees for a target hsi image.
        %>
        %> The reference library @c hsiUtility.GetReferenceLibrary() needs to be set beforehand.
        %>
        %> @b Usage
        %>
        %> @code
        %> scoreImg = hsi.SAMscore(hsIm);
        %> @endcode
        %>
        %> @param obj [hsi] | An hsi instance
        %>
        %> @retval scoreImg [array] | The SAM score
        %======================================================================
        function [scoreImg] = SAMscore(obj)
            %======================================================================
            %> @brief hsi.SAMscore returns SAM silimarity scores compared to a healthy tissue signature in degrees for a target hsi image.
            %>
            %> The reference library @c hsiUtility.GetReferenceLibrary() needs to be set beforehand.
            %>
            %> @b Usage
            %>
            %> @code
            %> scoreImg = hsi.SAMscore(hsIm);
            %> @endcode
            %>
            %> @param obj [hsi] | An hsi instance
            %>
            %> @retval scoreImg [array] | The SAM score
            %======================================================================
            refLib = hsiUtility.GetReferenceLibrary();
            xCol = obj.GetMaskedPixels();
            pixelN = size(xCol, 1);

            disp('SAM calculated only against a healthy skin signature.');
            reference = refLib(5).Data;
            samVals = sam(permute(xCol, [3, 1, 2]), reference);
            samVals = rad2deg(samVals);

            scoreImg = hsi.RecoverSpatialDimensions(samVals', size(obj.FgMask), obj.FgMask);
        end

        %======================================================================
        %> @brief hsi.ArgminSAM returns SAM scores for a target hsi image.
        %>
        %> The reference library @c hsiUtility.GetReferenceLibrary() needs to be set beforehand.
        %>
        %> @b Usage
        %>
        %> @code
        %> [scoreImg, labelImg, argminImg] = hsi.ArgminSAM(hsIm);
        %> @endcode
        %>
        %> @param obj [hsi] | An hsi instance
        %>
        %> @retval scoreImg [array] | The minimum SAM score
        %> @retval labelImg [array] | The labels of minimum SAM score
        %> @retval argminImg [array] | The argmin of minimum SAM score
        %======================================================================
        function [scoreImg, labelImg, argminImg] = ArgminSAM(obj)
            %======================================================================
            %> @brief hsi.ArgminSAM returns SAM scores for a target hsi image.
            %>
            %> The reference library @c hsiUtility.GetReferenceLibrary() needs to be set beforehand.
            %>
            %> @b Usage
            %>
            %> @code
            %> [scoreImg, labelImg, argminImg] = hsi.ArgminSAM(hsIm);
            %> @endcode
            %>
            %> @param obj [hsi] | An hsi instance
            %>
            %> @retval scoreImg [array] | The minimum SAM score
            %> @retval labelImg [array] | The labels of minimum SAM score
            %> @retval argminImg [array] | The argmin of minimum SAM score
            %======================================================================
            refLib = hsiUtility.GetReferenceLibrary();
            xCol = obj.GetMaskedPixels();
            pixelN = size(xCol, 1);

            samVals = zeros(numel(refLib), pixelN);
            for jj = 5
                samVals(jj, :) = sam(permute(xCol, [3, 1, 2]), refLib(jj).Data);
            end
            [scoreImg, argminImg] = min(samVals, [], 1);
            labelImg = arrayfun(@(x) refLib(x).Label, argminImg);

            scoreImg = hsi.RecoverSpatialDimensions(scoreImg', size(obj.FgMask), obj.FgMask);
            labelImg = hsi.RecoverSpatialDimensions(labelImg', size(obj.FgMask), obj.FgMask);
            argminImg = hsi.RecoverSpatialDimensions(argminImg', size(obj.FgMask), obj.FgMask);

            labelImg = uint8(labelImg);
            argminImg = uint8(argminImg);
        end

        % ======================================================================
        %> @brief hsi.Applies a specific function to the values of an hsi object.
        %>
        %> Depending on the target function and value change some functions of the hsi class may produce errors or wrong results.
        %>
        %> @b Usage
        %>
        %> @code
        %> %Crop only a slice of the blue spectral range
        %> transformFun = @(x) x(:,:,30:50);
        %> resultObj = hsIm.ApplyFucntion(tranformFun);
        %> @endcode
        %>
        %> @param obj [hsi] | An instance of the hsi class
        %> @param transformFun [function handle] | The function handle for the function to be applied.
        %> @param varargin [cell array] | The arguments necessary for the target function
        %>
        %> @retval resultObj [hsi] | An instance of the hsi class
        % ======================================================================
        function [resultObj] = ApplyFunction(obj, transformFun, varargin)
            % ======================================================================
            %> @brief hsi.Applies a specific function to the values of an hsi object.
            %>
            %> Depending on the target function and value change some functions of the hsi class may produce errors or wrong results.
            %>
            %> @b Usage
            %>
            %> @code
            %> %Crop only a slice of the blue spectral range
            %> transformFun = @(x) x(:,:,30:50);
            %> resultObj = hsIm.ApplyFucntion(tranformFun);
            %> @endcode
            %>
            %> @param obj [hsi] | An instance of the hsi class
            %> @param transformFun [function handle] | The function handle for the function to be applied.
            %> @param varargin [cell array] | The arguments necessary for the target function
            %>
            %> @retval resultObj [hsi] | An instance of the hsi class
            % ======================================================================

            resultObj = obj;
            scores = transformFun(obj.Value, varargin{:});
            resultObj.Value = scores;
        end

        % ======================================================================
        %> @brief hsi.Denoise applies denoising to an hsi object.
        %>
        %> @b Usage
        %>
        %> @code
        %> [corrected] = hsIm.Denoise();
        %>
        %> [corrected] = hsIm.Denoise('smile');
        %> @endcode
        %>
        %> @param obj [hsi] | An instance of the hsi class
        %> @param method [char] | Optional: The denoising method, either 'smile' or 'smoothen'. Default: 'smile'.
        %>
        %> @retval corrected [hsi] | An instance of the hsi class
        % ======================================================================
        function [corrected] = Denoise(obj, method)
            % ======================================================================
            %> @brief hsi.Denoise applies denoising to an hsi object.
            %>
            %> @b Usage
            %>
            %> @code
            %> [corrected] = hsIm.Denoise();
            %>
            %> [corrected] = hsIm.Denoise('smile');
            %> @endcode
            %>
            %> @param obj [hsi] | An instance of the hsi class
            %> @param method [char] | Optional: The denoising method, either 'smile' or 'smoothen'. Default: 'smile'.
            %>
            %> @retval corrected [hsi] | An instance of the hsi class
            % ======================================================================

            if nargin < 2
                method = 'smile';
            end
            corrected = obj;
            if strcmpi(method, 'smile')
                corrected.Value = reduceSmile(obj.Value);
            elseif strcmpi(method, 'smoothen')
                corrected.Value = denoiseNGMeet(obj.Value);
            else
                error('Unsupported method. Choose [smile] or [smoothen].');
            end
        end
    end

    methods (Static)

        %======================================================================
        %> @brief hsi.Load recovers the saved instance for the targetID
        %>
        %> In order to work properly it need the argument to be read and preprocessed first.
        %> Use @c function hsiUtility.PrepareDataset for initialization.
        %>
        %> @b Usage
        %>
        %> @code
        %>  config.SetSetting('Normalization', 'raw');
        %>  spectralData = hsi.Load(targetName);
        %>
        %>  spectralData = hsi.Load(targetName, 'dataset');
        %>
        %>  config.SetSetting('Normalization', 'byPixel');
        %>  spectralData = hsi.Load(targetName, 'preprocessed');
        %> @endcode
        %>
        %> @param targetID [char] | The unique ID of the target sample
        %> @param dataType [char] | Either 'dataset', 'preprocessed' or 'raw'
        %>
        %> @retval obj [hsi] | The loaded hsi object
        %======================================================================
        function [obj] = Load(targetID, dataType)
            %======================================================================
            %> @brief hsi.Load recovers the saved instance for the targetID
            %>
            %> In order to work properly it need the argument to be read and preprocessed first.
            %> Use @c function hsiUtility.PrepareDataset for initialization.
            %>
            %> @b Usage
            %>
            %> @code
            %>  config.SetSetting('Normalization', 'raw');
            %>  spectralData = hsi.Load(targetName);
            %>
            %>  spectralData = hsi.Load(targetName, 'dataset');
            %>
            %>  config.SetSetting('Normalization', 'byPixel');
            %>  spectralData = hsi.Load(targetName, 'preprocessed');
            %> @endcode
            %>
            %> @param targetID [char] | The unique ID of the target sample
            %> @param dataType [char] | Either 'dataset', 'preprocessed' or 'raw'
            %>
            %> @retval obj [hsi] | The loaded hsi object
            %======================================================================

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
                fprintf('Loads from dataset %s with normalization %s.\n', config.GetSetting('Dataset'), config.GetSetting('Normalization'));
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
        %> @brief hsi.RecoverSpatialDimensions recovers the original spatial dimension
        %> from masked pixels.
        %>
        %> Data with original spatial dimensions and reduced spectral dimensions
        %> For more details check @c function RecoverOriginalDimensionsInternal.
        %>
        %> @b Usage
        %>
        %> @code
        %> [recHsi] = hsi.RecoverSpatialDimensions(redIm, origSize, mask);
        %>
        %> [recHsi] = hsi.RecoverSpatialDimensions(scores, imgSizes, masks);
        %> @endcode
        %>
        %> @param obj [hsi] | An hsi instance
        %> @param origSize [cell array] | Original sizes of input data (array or cell of arrays)
        %> @param mask [cell array] | Optional: Masks per data sample (array or cell of arrays)
        %>
        %> @retval obj [hsi] | The reconstructed hsi instance
        %======================================================================
        function [recHsi] = RecoverSpatialDimensions(varargin)
            %======================================================================
            %> @brief hsi.RecoverSpatialDimensions recovers the original spatial dimension
            %> from masked pixels.
            %>
            %> Data with original spatial dimensions and reduced spectral dimensions
            %> For more details check @c function RecoverOriginalDimensionsInternal.
            %>
            %> @b Usage
            %>
            %> @code
            %> [recHsi] = hsi.RecoverSpatialDimensions(redIm, origSize, mask);
            %>
            %> [recHsi] = hsi.RecoverSpatialDimensions(scores, imgSizes, masks);
            %> @endcode
            %>
            %> @param obj [hsi] | An hsi instance
            %> @param origSize [cell array] | Original sizes of input data (array or cell of arrays)
            %> @param mask [cell array] | Optional: Masks per data sample (array or cell of arrays)
            %>
            %> @retval obj [hsi] | The reconstructed hsi instance
            %======================================================================

            [recHsi] = RecoverOriginalDimensionsInternal(varargin{:});
        end

        %======================================================================
        %> @brief hsi.IsHsi checks if a variable is of an hsi instance
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
            %======================================================================
            %> @brief hsi.IsHsi checks if a variable is of an hsi instance
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

            flag = isequal(class(obj), 'hsi');
        end

    end
end