function [curDir] = GetConfDir()
%% GETCONFDIR returns the configuration dir for the current project 

curDir = fullfile(GetRunBaseDir(), 'conf');

end 