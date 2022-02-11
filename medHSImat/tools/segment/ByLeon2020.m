function [labels] = ByLeon2020(hsIm, segopt)
%
%   Usage:
%   segopt = segment.GetOptions('Leon2020');
%   labels = segment.Apply(hsIm, targetName, segopt);
%
%   labels = ByLeon2020(hsIm, segopt);

    k = segopt.MainClasses;
    voting = segopt.VotingScheme;
    mainSegFun = segopt.MainSegmentation;

    refLibrary = hsiUtility.GetReferenceLibrary();
    n = numel(refLibrary);

    if options.HasInitialSegmentation
        kin = segopt.InitialClasses;
        initSegFun = segopt.segment.Kmeans;
        [labelsInit, centroids] = initSegFun(hsIm, kin);
        %% Segmenet first class as background with label -1 
        %% 
        unit = options.MainUnit; 
        labels = ones(size(labelsInit)) * (-1);
        for i = 1:kin
            mask = labelsInit == i;
            colPixels = hsIm.GetPixelsFromMask(mask);

            if strcmpi(unit, 'pixel')
            %% Assign label by cluster pixels 
                samVal = zeros(n,1);
                for j = 1:n
                    if strcmpi(voting, 'MinimumSum')
                        for k = 1:size(colPixels, 1)
                            samVal(j) = samVal(j) + sam(colPixels(k,:), refLibrary(j).Data);
                        end        
                        idMin = samVal == min(samVal);
                        labelCentroid = refLibrary(idMin).Label;
                        labels(mask) = labelCentroid;
                    else 
                        error('Not supported.');
                    end
                end

            elseif strcmpi(unit, 'centroid')
                %% Assign label by cluster centroid    

                samVal = zeros(n,1);
                for j = 1:n
                    samVal(j) = sam(centroids(i,:), refLibrary(j).Data);
                end

                if strcmpi(voting, 'Minimum')
                    idMin = samVal == min(samVal);
                    labelCentroid = refLibrary(idMin).Label;
                else 
                    error('Not supported.');
                end
                labels(mask) = labelCentroid;
            else 
                error('Not supported.');
            end
        end 

    else
        labels = mainSegFun(hsiIm, targetName, k);
    end
end
        