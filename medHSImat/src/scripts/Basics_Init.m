%======================================================================
%> @brief Basics_Init prepares the initialization settings for
%> according to the experiment and the selected dataset.
%>
%> @b Usage
%>
%> @code
%> Basics_Init(experiment, dataset);
%> @endcode
%>
%> @param experiment [char] | The name of the experiment
%> @param dataset [char] | Optional: The name of the dataset.Default: config::[Dataset].
%======================================================================
function [] = Basics_Init(experiment, dataset)
% Basics_Init prepares the initialization settings for
% according to the experiment and the selected dataset.
%
% @b Usage
%
% @code
% Basics_Init(experiment, dataset);
% @endcode
%
% @param experiment [char] | The name of the experiment
% @param dataset [char] | Optional: The name of the dataset.Default: config::[Dataset].
close all;
clc;

if nargin > 1
    config.SetSetting('Dataset', dataset);
end

rng(1); % For reproducibility

config.SetSetting('Experiment', experiment);
config.SetSetting('SaveFolder', experiment);
config.SetSetting('ShowFigures', true);

fprintf('Running for dataset %s\n', config.GetSetting('Dataset'));
end