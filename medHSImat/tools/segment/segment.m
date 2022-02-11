classdef segment
    methods (Static)

        %% Contents
        %
        %   Static:
        %   [segMask] = Apply(hsi, options)
        %   segopt = GetOptions(option)

        function [labels] = Apply(hsIm, targetName, segopt)
            
            labels = mainSegFun(hsiIm, segopt);
                        
            if segopt.HasPostProcessing
                postProcFun = segopt.PostProcessingScheme;
                labels = postProcFun(labels);
            end 
        end
        
        function segopt = GetOptions(option)
            segopt = struct('HasInitialSegmentation', False, 'InitialSegmentation', [], 'InitialClasses', [], ...
                'MainSegmentation', [], 'MainClasses', [], 'VotingScheme', [], ...
                'MainUnit', [], 'HasPostProcessing', False, 'PostProcessingScheme', []);
            switch option
                case 'Leon2020'
                    segopt = struct('HasInitialSegmentation', True, 'InitialSegmentation', @segment.Kmeans, 'InitialClasses', 3, ...
                        'MainSegmentation', @ByLeon2020, 'MainClasses', 7, 'VotingScheme', 'MinimumSum', ...
                        'MainUnit', 'Pixel', 'HasPostProcessing', True, 'PostProcessingScheme', @MorphologicalOps);
                case 'Leon2020b'
                    segopt = struct('HasInitialSegmentation', True, 'InitialSegmentation', @segment.Kmeans, 'InitialClasses', 3, ...
                        'MainSegmentation', @ByLeon2020, 'MainClasses', 7, 'VotingScheme', 'Minimum', ...
                        'MainUnit', 'Centroid', 'HasPostProcessing', True, 'PostProcessingScheme', @MorphologicalOps);
            end
        end
        
        function [labels, represenatives] = Kmeans(hsIm, clusterNum)
            fgMask = hsIm.FgMask;
            Xcol = hsIm.GetPixelsFromMask(fgMask);
            [labels, represenatives] = kmeans(Xcol, clusterNum);
        end
        
        function [outLabels] = MorphologicalOps(inLabels)
            BW = imbinarize(inLabels);
            BW2 = imfill(BW,'holes');
            se = strel('disk',5);
            outLabels = imclose(BW2, se);
        end
    end
end