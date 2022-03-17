
%======================================================================
%> @brief Basics_SplitTrain prepares the settings for train-test split
%> according to the experiment and the selected dataset.
%>
%> @b Usage
%>
%> @code
%> [X, y, Xtest, ytest, cvp, sRGBs, fgMasks] = Basics_SplitTrain(experiment, dataset);
%> @endcode
%>
%> @param experiment [char] | The name of the experiment
%> @param dataset [char] | The name of the dataset
%>
%> @retval X [numeric array] | The train data
%> @retval y [numeric array] | The train values
%> @retval Xtest [numeric array] | The test data
%> @retval ytest [numeric array] | The test values
%> @retval cvp [cell array] | The cross validation index splits
%> @retval sRGBs [cell array] | The array of sRGBs for test hsi data
%> @retval fgMasks [cell array] | The foreground masks of sRGBs for test hsi data
%>
%======================================================================
function [X, y, Xtest, ytest, cvp, sRGBs, fgMasks] = Basics_SplitTrain(experiment, dataset)
% Basics_SplitTrain prepares the settings for train-test split
% according to the experiment and the selected dataset.
%
% @b Usage
%
% @code
% [X, y, Xtest, ytest, cvp, sRGBs, fgMasks] = Basics_SplitTrain(experiment, dataset);
% @endcode
%
% @param experiment [char] | The name of the experiment
% @param dataset [char] | The name of the dataset
%
% @retval X [numeric array] | The train data
% @retval y [numeric array] | The train values
% @retval Xtest [numeric array] | The test data
% @retval ytest [numeric array] | The test values
% @retval cvp [cell array] | The cross validation index splits
% @retval sRGBs [cell array] | The array of sRGBs for test hsi data
% @retval fgMasks [cell array] | The foreground masks of sRGBs for test hsi data
%
    Basics_Init(experiment, dataset);

    folds = 5;
    testTargets = {}; % {'166'};
    dataType = 'hsi';
    hasLabels = true;

    [X, y, Xtest, ytest, cvp, sRGBs, fgMasks] = trainUtility.SplitTrainTest(config.GetSetting('dataset'), testTargets, dataType, hasLabels, folds);

end
