% ======================================================================
%> @brief segment is a class that handles segmentation of hyperspectral data.
%>
% ======================================================================
classdef segment
    methods (Static)

        function [postMaskPredict] = MorphologicalOps(maskPredict)
        % ======================================================================
        %> @brief segment.MorphologicalOps applies morphological operators on the
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
        
            BW = imbinarize(maskPredict);
            BW2 = imfill(BW, 'holes');
            se = strel('disk', 5);
            postMaskPredict = imclose(BW2, se);
        end
        
        function [prediction] = Apply(hsiIm, method, varargin)
            switch method
                case lower('Leon')
                    prediction = segmentLeon(hsiIm);
                    
                case lower('SAM')
                    [prediction, ~, ~] = segmentSAM(hsiIm, varargin{:});
                    
                case lower('HSI')
                    
                otherwise
                    error('Incorrect method');
            end
        end
        
        function [] = ApplyAndShow(method)
                     
            switch method
                case lower('Leon')
                    experiment = 'ByLeon';
                    Basics_Init(experiment);
                    
                    apply.ToEach(@LeonAndShow);
                    plots.GetMontagetCollection(1, 'clusters');
                    plots.GetMontagetCollection(2, 'leon');
                    
                case lower('SAM-library')
                    experiment = 'SAM-BCC&MCC';
                    Basics_Init(experiment);
                    
                    apply.ToEach(@SAMAndShow);
                    plots.GetMontagetCollection(1, 'predLabel');
                    
                case lower('SAM-healthy')
                    experiment = 'SAM-Healthy';
                    Basics_Init(experiment);
                    
                    threshold = 13;
                    apply.ToEach(@SAMAndShow, 'healthy', threshold);
                    plots.GetMontagetCollection(1, 'predLabel');
                
                case lower('Kmeans')
                    experiment = 'Kmeans';
                    Basics_Init(experiment);

                    apply.ToEach(@KmeansAndShow, 5);
                    plots.GetMontagetCollection(1, 'kmeans-clustering');
                    plots.GetMontagetCollection(2, 'kmeans-centroids');
            
                case lower('HSI')
                    
                otherwise
                    error('Incorrect method');
            end
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
