% ======================================================================
%> @brief segment is a class that handles segmentation of hyperspectral data.
%>
% ======================================================================
classdef segment
    methods (Static)

        % ======================================================================
        %> @brief Apply implements segmentation according to options.
        % ======================================================================
        function Apply(fig, hsIm, endmembers, funHandle, labelInfo, saveName)
            numEndmembers = size(endmembers, 2);
            colSum = sum(endmembers, 1);
            n = sum(colSum > 0); 
            score = zeros(size(hsIm.Value,1),size(hsIm.Value,2), n);
            k = 0;
            for i= 1:numEndmembers
                if colSum(i) > 0
                    k = k + 1;
                    score(:,:,k) = funHandle(hsIm.Value,endmembers(:,i));
                end
            end

            [~,matchingIndx] = min(score,[],3);

            savedir = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), config.GetSetting('FileName')), '');
            srgb = hsIm.GetDisplayImage();
            img = {srgb, matchingIndx};
            names = {labelInfo.Diagnosis, 'Clustering'};
            plotPath = fullfile(savedir, saveName);
            plots.MontageWithLabel(fig, plotPath, img, names, labelInfo.Labels, hsIm.FgMask);        
            
            fig2 = figure(fig+1); clf;
            abundanceMap = estimateAbundanceLS(hsIm.Value,endmembers);
            montage(abundanceMap,'Size',[2 4],'BorderSize',[10 10]);
            colormap default
            title('Abundance Maps for Endmembers');
            plotPath = fullfile(savedir, strcat(saveName, '_abundance'));
            plots.SavePlot(fig2, plotPath);
        end
        
        
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
        function [labels] = ApplyOld(hsIm, segopt)
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
            config.SetSetting('FileName', hsIm.ID);

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
            plots.GetMontagetCollection(1, 'predLabel');
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

        function ByPCA()
            experiment = strcat('PCA');
            Basics_Init(experiment);
            pcNum = 3;
            apply.ToEach(@DimredAnalysis, 'pca', pcNum);
        end


        function BySuperPCA()

            %% SuperPCA
            pixelNum = 20;
            pcNum = 5;

            %% Manual
            experiment = 'SuperPCA-Manual';
            Basics_Init(experiment);

            isManual = true;
            apply.ToEach(@SuperpixelAnalysis, isManual, pixelNum, pcNum);

            close all;
            if config.GetSetting('IsTest')
                plots.GetMontagetCollection(1, 'eigenvectors');
            end
            plots.GetMontagetCollection(2, 'superpixel_mask');
            plots.GetMontagetCollection(3, 'pc1');
            plots.GetMontagetCollection(4, 'pc2');
            plots.GetMontagetCollection(5, 'pc3');

            %% From SuperPCA package
            experiment = 'SuperPCA';
            Basics_Init(experiment);

            isManual = false;
            apply.ToEach(@SuperpixelAnalysis, isManual, pixelNum, pcNum);

            close all;
            if config.GetSetting('IsTest')
                plots.GetMontagetCollection(1, 'eigenvectors');
            end
            plots.GetMontagetCollection(2, 'superpixel_mask');
            plots.GetMontagetCollection(3, 'pc1');
            plots.GetMontagetCollection(4, 'pc2');
            plots.GetMontagetCollection(5, 'pc3');
        end

        function ByMSuperPCA()

            %% Multiscale SuperPCA
            experiment = strcat('MultiscaleSuperPCA-Manual');
            Basics_Init(experiment);

            pixelNumArray = floor(50*sqrt(2).^[-2:2]);
            apply.ToEach(@MultiscaleSuperpixelAnalysis, pixelNumArray);
        end

        function By_Kmeans()
            experiment = 'Kmeans';
            Basics_Init(experiment);

            apply.ToEach(@CustomKmeans, 5);
            plots.GetMontagetCollection(1, 'kmeans-clustering');
            plots.GetMontagetCollection(2, 'kmeans-centroids');
        end
        
        function By_HyperspectralToolbox()
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

        function By_CustomDistances()
            reductionMethod = 'MNF';
            experiment = strcat('CustomDistances', '-', reductionMethod, '-8');
            Basics_Init(experiment);
            apply.ToEach(@CustomDistancesSegmentation, reductionMethod, 'nfindr');   
        end
    end

end
