% ======================================================================
%> @brief segment is a class that handles segmentation of hyperspectral data.
%>
% ======================================================================
classdef segment
    methods (Static)

        % ======================================================================
        %> @brief Apply implements segmentation according to options.
        %>
        %> @b Usage
        %>
        %> @code
        %> segopt = segopt.GetOptions('Leon2020');
        %> labels = segment.Apply(hsIm, segopt);
        %> @endcode
        %>
        %> @param hsIm [hsi] | An instance of the hsi class
        %> @param segopt [struct] | The segmentation options
        %>
        %> @retval labels [numeric array] | The segmented labels
        % ======================================================================
        function [labels] = Apply(hsIm, segopt)
            % Apply implements segmentation according to options.
            %
            % @b Usage
            %
            % @code
            % segopt = segopt.GetOptions('Leon2020');
            % labels = segment.Apply(hsIm, segopt);
            % @endcode
            %
            % @param hsIm [hsi] | An instance of the hsi class
            % @param segopt [struct] | The segmentation options
            %
            % @retval labels [numeric array] | The segmented labels
            config.SetSetting('fileName', hsIm.ID);

            labels = mainSegFun(hsiIm, segopt);

            if segopt.HasPostProcessing
                postProcFun = segopt.PostProcessingScheme;
                labels = postProcFun(labels);
            end
        end

        % ======================================================================
        %> @brief GetOptions prepares the settings for segmentation.
        %>
        %> YOU CAN UPDATE THIS FUNCTION ACCORDING TO YOUR SPECIFICATIONS.
        %>
        %> @b Usage
        %>
        %> @code
        %> segopt = segopt.GetOptions('Leon2020');
        %> labels = segment.Apply(hsIm, segopt);
        %> @endcode
        %>
        %> @retval segopt [struct] | The segmentation options
        %>
        % ======================================================================
        function segopt = GetOptions(option)
            % GetOptions prepares the settings for segmentation.
            %
            % YOU CAN UPDATE THIS FUNCTION ACCORDING TO YOUR SPECIFICATIONS.
            %
            % @b Usage
            %
            % @code
            % segopt = segment.GetOptions('Leon2020');
            % labels = segment.Apply(hsIm, segopt);
            % @endcode
            %
            % @retval segopt [struct] | The segmentation options
            %
            segopt = struct('HasInitialSegmentation', False, 'InitialSegmentation', [], 'InitialClasses', [], ...
                'MainSegmentation', [], 'MainClasses', [], 'VotingScheme', [], ...
                'MainUnit', [], 'HasPostProcessing', False, 'PostProcessingScheme', []);
            switch option
                case 'Leon2020'
                    segopt = struct('HasInitialSegmentation', True, 'InitialSegmentation', @CustomKmeans, 'InitialClasses', 3, ...
                        'MainSegmentation', @ByLeon2020, 'MainClasses', 7, 'VotingScheme', 'MinimumSum', ...
                        'MainUnit', 'Pixel', 'HasPostProcessing', True, 'PostProcessingScheme', @segment.MorphologicalOps);

                case 'Leon2020b'
                    segopt = struct('HasInitialSegmentation', True, 'InitialSegmentation', @CustomKmeans, 'InitialClasses', 3, ...
                        'MainSegmentation', @ByLeon2020, 'MainClasses', 7, 'VotingScheme', 'Minimum', ...
                        'MainUnit', 'Centroid', 'HasPostProcessing', True, 'PostProcessingScheme', @segment.MorphologicalOps);
            end
        end

        % ======================================================================
        %> @brief MorphologicalOps applies morpholigical operators on the
        %> segmented labels.
        %>
        %> This function closes holes in the segmented mask.
        %>
        %> @b Usage
        %>
        %> @code
        %> outLabels = segment.MorphologicalOps(inLabels);
        %> @endcode
        %>
        %> @param inLabels [numeric array] | The input labels
        %>
        %> @retval outLabels [numeric array] | The output labels
        %>
        % ======================================================================
        function [outLabels] = MorphologicalOps(inLabels)
            % MorphologicalOps applies morpholigical operators on the
            % segmented labels.
            %
            % This function closes holes in the segmented mask.
            %
            % @b Usage
            %
            % @code
            % outLabels = segment.MorphologicalOps(inLabels);
            % @endcode
            %
            % @param inLabels [numeric array] | The input labels
            %
            % @retval outLabels [numeric array] | The output labels
            %
            BW = imbinarize(inLabels);
            BW2 = imfill(BW, 'holes');
            se = strel('disk', 5);
            outLabels = imclose(BW2, se);
        end

        function BySAM()

            experiment = strcat('SAM segmentation-BCC&MCC');
            Basics_Init(experiment);

            apply.ToEach(@SAMAnalysis);
            plots.GetMontagetCollection('predLabel');
        end

        function ByICA()
            experiment = strcat('FastICA');
            Basics_Init(experiment);
            icNum = 3;
            apply.ToEach(@DimredAnalysis, 'ica', icNum);
        end
        
        function ByRICA()
            experiment = strcat('RICA');
            Basics_Init(experiment);
            icNum = 3;
            apply.ToEach(@DimredAnalysis, 'rica', icNum);
        end
        
        function BySuperPCA()

            %% SuperPCA
            pixelNum = 20;
            pcNum = 5;

            %% Manual
            experiment = strcat('SuperPCA-Manual', date());
            Basics_Init(experiment);

            isManual = true;
            apply.ToEach(@SuperpixelAnalysis, isManual, pixelNum, pcNum);

            close all;
            if config.GetSetting('isTest')
                plots.GetMontagetCollection(1, 'eigenvectors');
            end
            plots.GetMontagetCollection(2, 'superpixel_mask');
            plots.GetMontagetCollection(3, 'pc1');
            plots.GetMontagetCollection(4, 'pc2');
            plots.GetMontagetCollection(5, 'pc3');

            %% From SuperPCA package
            experiment = strcat('SuperPCA', date());
            Basics_Init(experiment);

            isManual = false;
            apply.ToEach(@SuperpixelAnalysis, isManual, pixelNum, pcNum);

            close all;
            if config.GetSetting('isTest')
                plots.GetMontagetCollection(1, 'eigenvectors');
            end
            plots.GetMontagetCollection(2, 'superpixel_mask');
            plots.GetMontagetCollection(3, 'pc1');
            plots.GetMontagetCollection(4, 'pc2');
            plots.GetMontagetCollection(5, 'pc3');
        end

        function ByMSuperPCA()

            %% Multiscale SuperPCA
            experiment = strcat('MultiscaleSuperPCA-Manual', date());
            Basics_Init(experiment);

            pixelNumArray = floor(50*sqrt(2).^[-2:2]);
            apply.ToEach(@MultiscaleSuperpixelAnalysis, pixelNumArray);
        end
    end

end
