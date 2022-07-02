% ======================================================================
%> @brief segment is a class that handles segmentation of hyperspectral data.
%>
% ======================================================================
classdef segment
    methods (Static)

        % ======================================================================
        %> @brief MorphologicalOps applies morpholigical operators on the
        %> segmented labels.
        %>
        %> This function closes holes in the segmented mask.
        %>
        %> @b Usage
        %>
        %> @code
        %> postMaskPredict = segment.MorphologicalOps(maskPredict);
        %> @endcode
        %>
        %> @param maskPredict [numeric array] | The input labels
        %>
        %> @retval postMaskPredict [numeric array] | The output labels
        %>
        % ======================================================================
        function [postMaskPredict] = MorphologicalOps(maskPredict)
            % MorphologicalOps applies morpholigical operators on the
            % segmented labels.
            %
            % This function closes holes in the segmented mask.
            %
            % @b Usage
            %
            % @code
            % postMaskPredict = segment.MorphologicalOps(maskPredict);
            % @endcode
            %
            % @param maskPredict [numeric array] | The input labels
            %
            % @retval postMaskPredict [numeric array] | The output labels
            %
            BW = imbinarize(maskPredict);
            BW2 = imfill(BW, 'holes');
            se = strel('disk', 5);
            postMaskPredict = imclose(BW2, se);
        end

        function ByLeon()
            % ByLeon applies segmentation based on Leon et al (2019).
            %
            % The method is applied on each image in the dataset. The results are saved in the output folder.
            %
            % @b Usage
            %
            % @code
            % segment.ByLeon();
            % @endcode
            experiment = 'ByLeon';
            Basics_Init(experiment);

            apply.ToEach(@SegmentLeonInternal);
            plots.GetMontagetCollection(1, 'clusters');
            plots.GetMontagetCollection(2, 'leon');
        end
        
        % ======================================================================
        %> @brief BySAM applies SAM-based clustering.
        %>
        %> The method is applied on each image in the dataset. The results are saved in the output folder.
        %>
        %> @b Usage
        %>
        %> @code
        %> segment.BySAM();
        %> @endcode
        % ======================================================================
        function BySAM()
            % BySAM applies SAM-based clustering.
            %
            % The method is applied on each image in the dataset. The results are saved in the output folder.
            %
            % @b Usage
            %
            % @code
            % segment.BySAM();
            % @endcode

            experiment = strcat('segmentation-BCC&MCC');
            Basics_Init(experiment);

            apply.ToEach(@SAMAnalysis);
            plots.GetMontagetCollection(1, 'predLabel');
        end

        function BySAM2()
            % BySAM2 applies SAM-based clustering.
            %
            % The method is applied on each image in the dataset. The results are saved in the output folder.
            %
            % @b Usage
            %
            % @code
            % segment.BySAM2();
            % @endcode

            experiment = strcat('SAM segmentation-Healthy');
            Basics_Init(experiment);

            threshold = 13;
            apply.ToEach(@SAMAnalysis, 'healthy', threshold);
            plots.GetMontagetCollection(1, 'predLabel');
        end

        % ======================================================================
        %> @brief ByKmeans applies Kmeans-based clustering.
        %>
        %> The method is applied on each image in the dataset. The results are saved in the output folder.
        %>
        %> @b Usage
        %>
        %> @code
        %> segment.ByKmeans();
        %> @endcode
        % ======================================================================
        function ByKmeans()
            % ByKmeans applies Kmeans-based clustering.
            %
            % The method is applied on each image in the dataset. The results are saved in the output folder.
            %
            % @b Usage
            %
            % @code
            % segment.ByKmeans();
            % @endcode
            experiment = 'Kmeans';
            Basics_Init(experiment);

            apply.ToEach(@CustomKmeans, 5);
            plots.GetMontagetCollection(1, 'kmeans-clustering');
            plots.GetMontagetCollection(2, 'kmeans-centroids');
        end

        % ======================================================================
        %> @brief ByHyperspectralToolbox applies Endmember-based clustering.
        %>
        %> The method is applied on each image in the dataset. The results are saved in the output folder.
        %>
        %> @b Usage
        %>
        %> @code
        %> segment.ByHyperspectralToolbox();
        %> @endcode
        % ======================================================================
        function ByHyperspectralToolbox()
            % ByHyperspectralToolbox applies Endmember-based clustering.
            %
            % The method is applied on each image in the dataset. The results are saved in the output folder.
            %
            % @b Usage
            %
            % @code
            % segment.ByHyperspectralToolbox();
            % @endcode

            reductionMethod = 'MNF';
            experiment = strcat('HStoolbox', '-', reductionMethod, '-8');
            Basics_Init(experiment);
            apply.ToEach(@HypercubeToolboxAnalysis, reductionMethod, 'nfindr');

            reductionMethod = 'PCA';
            experiment = strcat('HStoolbox', '-', reductionMethod, '-8');
            Basics_Init(experiment);
            apply.ToEach(@HypercubeToolboxAnalysis, reductionMethod, 'nfindr');

            reductionMethod = 'MNF';
            referenceMethod = 'ppi';
            experiment = strcat('HStoolbox', '-', reductionMethod, '-', referenceMethod, '-8');
            Basics_Init(experiment);
            apply.ToEach(@HypercubeToolboxAnalysis, reductionMethod, referenceMethod);

            reductionMethod = 'MNF';
            referenceMethod = 'fippi';
            experiment = strcat('HStoolbox', '-', reductionMethod, '-', referenceMethod, '-8');
            Basics_Init(experiment);
            apply.ToEach(@HypercubeToolboxAnalysis, reductionMethod, referenceMethod);
        end

        % ======================================================================
        %> @brief ByCustomDistances applies Distance-based clustering.
        %>
        %> The method is applied on each image in the dataset. The results are saved in the output folder.
        %>
        %> @b Usage
        %>
        %> @code
        %> segment.ByCustomDistances();
        %> @endcode
        % ======================================================================
        function ByCustomDistances()
            % ByCustomDistances applies Distance-based clustering.
            %
            % The method is applied on each image in the dataset. The results are saved in the output folder.
            %
            % @b Usage
            %
            % @code
            % segment.ByCustomDistances();
            % @endcode
            reductionMethod = 'MNF';
            experiment = strcat('CustomDistances', '-', reductionMethod, '-8');
            Basics_Init(experiment);
            apply.ToEach(@CustomDistancesSegmentation, reductionMethod, 'nfindr');
        end
    end

end
