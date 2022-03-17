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
%> @param dataset [char] | Optional: The name of the dataset.Default:
%> config::[dataset].
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
% @param dataset [char] | Optional: The name of the dataset.Default:
% config::[dataset].

if nargin > 1
    config.SetSetting('dataset', dataset);
end 

rng(1); % For reproducibility

config.SetSetting('experiment', experiment);
config.SetSetting('saveFolder', experiment);
config.SetSetting('showFigures', true);

fprintf('Running for dataset %s\n', config.GetSetting('dataset'));
end 