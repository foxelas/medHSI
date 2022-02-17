function [X, y, Xtest, ytest, cvp, sRGBs, fgMasks] = SplitTrainTestInternal(dataset, testTargets, dataType, hasLabels, folds, transformFun)
    %% SplitTrainTest rearranges pixels as a pixel (observation) by feature 2D array
    % One pixel is one data sample
    %
    %   Arguments 
    %   dataset: string, the folder name of dataset (must be in
    %   matfiles\hsi\)
    %   testTargets: array of str targetNames 
    %   dataType: 'image' or 'pixel'
    %   hasLabels: bool
    %   folds: numeric 
    %   transformFun: function handle
    %
    %   Usage:
    %   dataset = 'pslBase';
    %   testTargets = {'153'};
    %   dataType = 'pixel';
    %   [X, y, Xtest, ytest, cvp, sRGBs, fgMasks] = trainUtility.SplitTrainTest(dataset, testTargets, dataType);
    %
    %   hasLabels = true;
    %   transformFun = @Dimred;
    %   folds = 5;
    %   [X, y, Xtest, ytest, cvp, sRGBs, fgMasks] = trainUtility.SplitTrainTest(dataset, testTargets, dataType, hasLabels, folds, transformFun);

    hasTest = ~isempty(testTargets);
    if nargin < 4 
        hasLabels = true;
    end
    if nargin < 5 
        folds = 5;
    end 

    useTransform = ~(nargin < 6);

    %% Read h5 data
    config.SetSetting('dataset', dataset);
    [datanames, targetIDs] = dataUtility.DatasetInfo();

    X = [];
    y = [];
    Xtest = [];
    ytest = [];
    sRGBs = cell(length(testTargets), 1);
    fgMasks = cell(length(testTargets), 1);

    k = 0;
    for i = 1:length(targetIDs)

        baseTargetName = targetIDs{i};
        targetNames = datanames(contains(datanames, baseTargetName));

        for j = 1:numel(targetNames)
            targetName = targetNames{j};

            %% load HSI from .mat file
            [I, label] = hsiUtility.LoadHSIAndLabel(targetName, 'dataset');
                
            fgMask = I.FgMask;
            if ~isempty(label) %% TOREMOVE
            
            if strcmp(dataType, 'image')
                xdata = I.Value;
                if hasLabels
                    ydata = label;
                else 
                    ydata = [];
                end

            elseif strcmp(dataType, 'pixel')
                if useTransform
                    scores = transformFun(I);
                    Xcol = GetMaskedPixelsInternal(scores, fgMask);
                else
                    Xcol = I.GetMaskedPixels(fgMask);
                end
                xdata = Xcol;
                if hasLabels
                    ydata = GetMaskedPixelsInternal(label, fgMask);
                else 
                    ydata = [];
                end

            else
                error('Incorrect data type');
            end 

            if isempty(find(contains(testTargets, targetName), 1))
                if strcmp(dataType, 'image')
                    X = {X; xdata};
                    y = {y; ydata};
                else
                    X = [X; xdata];
                    y = [y; ydata];
                end

            else

                if strcmp(dataType, 'image')
                    Xtest = {Xtest; xdata};
                    ytest = {ytest; ydata};
                else
                    Xtest = [Xtest; xdata];
                    ytest = [ytest; ydata];
                end

                %%Recover Test Image
                k = k + 1;
                sRGBs{k} = I.GetDisplayRescaledImage();
                fgMasks{k} = fgMask;
            end
            end

        end
    end

    if ~isempty(y)
        cvp = trainUtility.KfoldPartitions(y, folds);
    else
        cvp = [];
    end
end
