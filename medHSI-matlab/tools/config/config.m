classdef config
    methods (Static)

        %% Contents
        %
        %   Static:
        %         SetOpt()
        %         [curDir] = GetRunBaseDir()
        %         [curDir] = GetConfDir()
        %         [filepath] = DirMake(varargin)
        %         [sourceDir] = GetSource()
        %         [hasGpu] = HasGPU()
        %         [value] = GetSetting(parameter)
        %         SetSetting(parameter, value)
        %         NotifySetting(paramName, paramValue)

        function [] = SetOpt()
            %     SETOPT sets parameters for running from conf/Config.ini
            %
            %     Usage:
            %     SetOpt()
            SetOpt();
        end

        function [curDir] = GetRunBaseDir()

            %% GETRUNBASEDIR returns the base dir for the current project

            currentDir = pwd;
            projectName = 'medHSI';
            parts = strsplit(currentDir, 'medHSI');
            curDir = fullfile(parts{1}, projectName);
        end

        function [curDir] = GetConfDir()

            %% GETCONFDIR returns the configuration dir for the current project

            curDir = fullfile(config.GetRunBaseDir(), 'conf');

        end

        function [filepath] = DirMake(varargin)

            %% DirMake creates a new directory
            %
            %     Usage:
            %     [filepath] = DirMake(filepath)
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

        function [sourceDir] = GetSource()
            %     GETSOURCE returns the source directory
            %
            %     Usage:
            %     sourceDir = GetSource()
            sourceDir = fullfile('..', '..', '..');
        end

        function [hasGpu] = HasGPU()
            %%HASGPU informs whether there is gpu available
            %
            %   Usage:
            %   hasGpu = HasGPU()
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

        function [value] = GetSetting(parameter)

            %% GETSETTING returns the value of a configurationParameter
            %
            %     Usage:
            %     value = getSetting('saveDir')
            settingsFile = fullfile(config.GetConfDir(), 'Config.mat');
            variableInfo = who('-file', settingsFile);
            if ismember(parameter, variableInfo)
                m = matfile(settingsFile);
                value = m.(parameter);
            else
                fprintf('Parameter %s does not exist in the configuration file.\n', parameter);
            end
        end

        function [] = SetSetting(parameter, value)

            %% SETSETTING sets a parameter according to a value or by default
            %
            %     Usage:
            %     SetSetting('saveDir', 'out\out')
            %     SetSetting('saveDir')
            settingsFile = fullfile(config.GetConfDir(), 'Config.mat');
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

        function [] = NotifySetting(paramName, paramValue)

            %% NOTIFYSETTING notifies about configuration parameter change
            %
            %     Usage:
            %     NotifySetting('saveDir', '\out\dir\')
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