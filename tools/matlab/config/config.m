classdef config  
    methods (Static)                  
        function [] = SetOpt()
            SetOpt();
        end
        
        %% GETRUNBASEDIR returns the base dir for the current project
        function [curDir] = GetRunBaseDir()
            currentDir = pwd;
            projectName = 'medHSI';
            parts = strsplit(currentDir, 'medHSI');
            curDir = fullfile(parts{1}, projectName);
        end
        
        %% GETCONFDIR returns the configuration dir for the current project
        function [curDir] = GetConfDir()

        curDir = fullfile(config.GetRunBaseDir(), 'conf');

        end

        %% DirMake creates a new directory
        %
        %     Usage:
        %     [filepath] = DirMake(filepath)
        function [filepath] = DirMake(varargin)
            if nargin == 1
                filepath = varargin{1};
            else
                filepath = fullfile(varargin{:});
            end
            fileDir = fileparts(filepath);
            if ~exist(fileDir, 'dir')
                mkdir(fileDir);
                if ~contains(fileDir, config.GetSetting('saveDir'))
                    addpath(fileDir);
                end
            end
        end

        %% GETFILECONDITIONS returns the conditions necessary for finding the
        %%filename of the file to be read
        %
        %   Usage:
        %   fileConditions = GetFileConditions(content, target)
        function [fileConditions] = GetFileConditions(content, target, id)

            if nargin < 2
                target = [];
            end
            if nargin < 3
                id = [];
            end


            if GetSetting('isTest')
                fileConditions = {content, [], config.GetSetting('dataDate'), id, ...
                    config.GetSetting('integrationTime'), target, GetSetting('configuration')};
            else
                fileConditions = {content, [], config.GetSetting('dataDate'), id, ...
                    config.GetSetting('integrationTime'), target, []};
            end
        end
        
        %     GETSOURCE returns the source directory
        %
        %     Usage:
        %     sourceDir = GetSource()        
        function sourceDir = GetSource()
            sourceDir = fullfile('..', '..', '..');
        end
 
        %%HASGPU informs whether there is gpu available
        %
        %   Usage:
        %   hasGpu = HasGPU()
        function [hasGpu] = HasGPU()
            v = dbstack;
            if numel(v) > 1
                parentName = v(2).name;
            else
                parentName = 'none';
            end
            isFirst = contains(parentName, 'initialization');
            if isFirst
                %pcName = char(java.net.InetAddress.getLocalHost.getHostName);
                %if stcmp(pcName, 'GPU-PC2') == 0
                if length(ver('parallel')) == 1
                    config.SetSetting('pcHasGPU', true);
                end
            end
            hasGpu = config.GetSetting('pcHasGPU');
        end

        %% GETSETTING returns the value of a configurationParameter
        %
        %     Usage:
        %     value = getSetting('saveDir')
        function [value] = GetSetting(parameter)
            settingsFile = fullfile(config.GetConfDir(), 'config.mat');
            variableInfo = who('-file', settingsFile);
            if ismember(parameter, variableInfo)
                m = matfile(settingsFile);
                value = m.(parameter);
            else
                fprintf('Parameter %s does not exist in the configuration file.\n', parameter);
            end
        end

        %% SETSETTING sets a parameter according to a value or by default
        %
        %     Usage:
        %     SetSetting('saveDir', 'out\out')
        %     SetSetting('saveDir')
        function [] = SetSetting(parameter, value)
            settingsFile = fullfile(config.GetConfDir(), 'config.mat');
            m = matfile(settingsFile, 'Writable', true);
            if nargin < 2 %write default value
                v = m.options;
                m.(parameter) = v.(parameter);
                value = v.(parameter);
            else
                m.(parameter) = value;
            end
            config.NotifySetting(parameter, value);
        end

        %% NOTIFYSETTING notifies about configuration parameter change
        %
        %     Usage:
        %     NotifySetting('saveDir', '\out\dir\')
        function [] = NotifySetting(paramName, paramValue)
            onOffOptions = {'OFF', 'ON'};
            if islogical(paramValue)
                fprintf('--Setting [%s] to %s.\n', paramName, onOffOptions{paramValue+1});
            elseif ischar(paramValue)
                fprintf('--Setting [%s] to %s.\n', paramName, paramValue);
            elseif isnumeric(paramValue)
                fprintf('--Setting [%s] to %.2f.\n', paramName, paramValue);
            else
                warning('Unsupported variable type.\n')
            end
        end

    end
end