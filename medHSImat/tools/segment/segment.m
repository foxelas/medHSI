% ======================================================================
%> @brief segment is a class that handles segmentation of hyperspectral data.
%>
% ======================================================================
classdef segment
    methods (Static)

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
        % ======================================================================
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
        % ======================================================================
            BW = imbinarize(maskPredict);
            BW2 = imfill(BW, 'holes');
            se = strel('disk', 5);
            postMaskPredict = imclose(BW2, se);
        end
        
        % ======================================================================
        %> @brief segment.Apply segments an hsi cube according to a method.
        %>
        %> For more information refer to @c SegmentLeon, @c SegmentSAM, @c SegmentKmeans and @c SegmentHypercubeToolbox.
        %>
        %> @b Usage
        %>
        %> @code
        %> prediction = segment.Apply(hsiIm, 'Leon');
        %> 
        %> prediction = segment.Apply(hsiIm, 'SAM', 'healthy', 13);
        %> @endcode
        %>
        %> @param hsIm [hsi] | An instance of the hsi class
        %> @param method [char] | The segmentation method. Optional: ['Leon', 'SAM', 'Kmeans', 'HypercubeToolbox']. 
        %> @param varargin [cell array] | The arguments necessary for the target method
        %>
        %> @retval prediction [numeric array] | The predicted labels
        % ======================================================================
        function [prediction] = Apply(hsiIm, method, varargin)
        % ======================================================================
        %> @brief segment.Apply segments an hsi cube according to a method.
        %>
        %> For more information refer to @c SegmentLeon, @c SegmentSAM, @c SegmentKmeans and @c SegmentHypercubeToolbox.
        %>
        %> @b Usage
        %>
        %> @code
        %> prediction = segment.Apply(hsiIm, 'Leon');
        %> 
        %> prediction = segment.Apply(hsiIm, 'SAM', 'healthy', 13);
        %> @endcode
        %>
        %> @param hsIm [hsi] | An instance of the hsi class
        %> @param method [char] | The segmentation method. Optional: ['Leon', 'SAM', 'Kmeans', 'HypercubeToolbox']. 
        %> @param varargin [cell array] | The arguments necessary for the target method
        %>
        %> @retval prediction [numeric array] | The predicted labels
        % ======================================================================
            switch method
                case lower('Leon')
                    prediction = SegmentLeon(hsiIm);
                    
                case lower('SAM')
                    [prediction, ~, ~] = SegmentSAM(hsiIm, varargin{:});
                
                case lower('Kmeans')
                    [prediction, ~] = SegmentKmeans(hsiIm, varargin{:});
                
                case lower('HypercubeToolbox')
                    prediction = SegmentHypercubeToolbox(hsiIm, varargin{:});
                    
                otherwise
                    error('Incorrect method');
            end
        end
        
        % ======================================================================
        %> @brief segment.ApplyAndShow segments an hsi cube according to a method and shows figures with the results.
        %>
        %> If a label hsiInfo exists, then comparison with labels is performed. 
        %>
        %> For more information refer to @c segment.Apply.
        %>
        %> @b Usage
        %>
        %> @code
        %> segment.ApplyAndShow('Leon');
        %> @endcode
        %>
        %> @param method [char] | The segmentation method. Optional: ['Leon', 'SAM-library', 'SAM-healthy', 'Kmeans', 'HypercubeToolbox']. 
        %> @param varargin [cell array] | The arguments necessary for the target method
        % ======================================================================
        function [] = ApplyAndShow(method, varargin)
        % ======================================================================
        %> @brief segment.ApplyAndShow segments an hsi cube according to a method and shows figures with the results.
        %>
        %> If a label hsiInfo exists, then comparison with labels is performed. 
        %>
        %> For more information refer to @c segment.Apply.
        %>
        %> @b Usage
        %>
        %> @code
        %> segment.ApplyAndShow('Leon');
        %> @endcode
        %>
        %> @param method [char] | The segmentation method. Optional: ['Leon', 'SAM-library', 'SAM-healthy', 'Kmeans', 'HypercubeToolbox']. 
        %> @param varargin [cell array] | The arguments necessary for the target method
        % ======================================================================
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
            
                case lower('HypercubeToolbox')
                    if isempty(varargin)
                        reductionMethod = 'MNF';
                        referenceMethod = 'Nfindr';
                        similarityMethod = 'SID';
                    else
                        reductionMethod = varargin{1};
                        referenceMethod = varargin{2};
                        similarityMethod = varargin{3};
                    end
                    
                    experiment = strcat('HStoolbox', '-', reductionMethod, '-', referenceMethod, '-', similarityMethod);
                    Basics_Init(experiment);

                    apply.ToEach(@HypercubeToolboxAndShow, reductionMethod, referenceMethod, similarityMethod);
                    plots.GetMontagetCollection(1, 'endmembers');
                    plots.GetMontagetCollection(2, 'clustering');
                    
                otherwise
                    error('Incorrect method');
            end
        end
        
    end

end
