% ======================================================================
%> @brief config is a class that holds the run configuration.
%
%> It is used to set and fetch options for running.
%> In order to refer to settings in the Config.ini file, the term
%> 'config::' is used.
%>
% ======================================================================
classdef config
    methods (Static)
        % ======================================================================
        %> @brief SetOpt sets parameters for running from Config.ini
        %>
        %> The values are recovered from MedHSIMat\\conf\\Config.ini.
        %> Then, the values are saved and accessed from a MedHSIMat\\conf\\Config.mat.
        %> Values are saved in an .ini format.
        %> For more details check @c function SetOpt .
        %>
        %> @b Usage
        %>
        %> @code
        %> config.SetOpt();
        %> @endcode
        %>
        % ======================================================================
        function [] = SetOpt()
            % SetOpt sets parameters for running from Config.ini
            %
            % The values are recovered from MedHSIMat\\conf\\Config.ini.
            % Then, the values are saved and accessed from a MedHSIMat\\conf\\Config.mat.
            % Values are saved in an .ini format.
            % For more details check @c function SetOpt .
            %
            % @b Usage
            %
            % @code
            % config.SetOpt();
            % @endcode
            %
            SetOpt();
        end
        % ======================================================================
        %> @brief GetRunBaseDir gets the base directory.
        %>
        %> The base directory is ...\\MedHSIMat.
        %>
        %> @b Usage
        %>
        %> @code
        %> curDir = config.GetRunBaseDir();
        %> @endcode
        %>
        %> @retval curDir [string] | The directory
        % ======================================================================
        function [curDir] = GetRunBaseDir()
            % GetRunBaseDir gets the base directory.
            %
            % The base directory is ...\\MedHSIMat.
            %
            % @b Usage
            %
            % @code
            % curDir = config.GetRunBaseDir();
            % @endcode
            %
            % @retval curDir [string] | The directory
            currentDir = pwd;
            projectName = 'medHSI';
            parts = strsplit(currentDir, 'medHSI');
            curDir = fullfile(parts{1}, projectName);
        end
        % ======================================================================
        %> @brief GetConfDir gets the directory of the configuration file.
        %>
        %> The configuration directory is ...\\MedHSIMat\\conf\\.
        %>
        %> @b Usage
        %>
        %> @code
        %> curDir = config.GetConfDir();
        %> @endcode
        %>
        %> @retval curDir [string] | The directory
        % ======================================================================
        function [curDir] = GetConfDir()
            % GetConfDir gets the directory of the configuration file.
            %
            % The configuration directory is ...\\MedHSIMat\\conf\\.
            %
            % @b Usage
            %
            % @code
            % curDir = config.GetConfDir();
            % @endcode
            %
            % @retval curDir [string] | The directory

            curDir = fullfile(config.GetRunBaseDir(), 'conf');

        end
        % ======================================================================
        %> @brief DirMake makes a new directory from folder and file parts.
        %>
        %> If the requested directory does not exist, it is created.
        %> If the directory is not a subdirectory of config::[OutputDir], then it
        %> is added to the matlab path.
        %>
        %> @b Usage
        %>
        %> @code
        %> filepath = config.DirMake(config.GetSetting('MatDir'), 'database-v10');
        %> @endcode
        %>
        %> @param varargin [cell array] | The fileparts of the directory
        %>
        %> @retval filepath [string] | The filepath
        % ======================================================================
        function [filepath] = DirMake(varargin)
            % DirMake makes a new directory from folder and file parts.
            %
            % If the requested directory does not exist, it is created.
            % If the directory is not a subdirectory of config::[OutputDir], then it
            % is added to the matlab path.
            %
            % @b Usage
            %
            % @code
            % filepath = config.DirMake(config.GetSetting('MatDir'), 'database-v10');
            % @endcode
            %
            % @param varargin [cell array] | The fileparts of the directory
            %
            % @retval filepath [string] | The filepath
            if nargin == 1
                filepath = varargin{1};
            else
                filepath = fullfile(varargin{:});
            end
            fileDir = fileparts(filepath);
            if ~exist(fileDir, 'dir')
                mkdir(fileDir);
                if ~contains(fileDir, config.GetSetting('OutputDir'))
                    addpath(fileDir);
                end
            end
        end

        % ======================================================================
        %> @brief HasGPU checkes whether a GPU is available.
        %>
        %> @b Usage
        %>
        %> @code
        %> flag = config.HasGPU();
        %> @endcode
        %>
        %> @retval flag [boolean] | The flag
        % ======================================================================
        function [hasGpu] = HasGPU()
            % HasGPU checkes whether a GPU is available.
            %
            % @b Usage
            %
            % @code
            % flag = config.HasGPU();
            % @endcode
            %
            % @retval flag [boolean] | The flag
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
                    config.SetSetting('PcHasGPU', true);
                end
            end
            hasGpu = config.GetSetting('PcHasGPU');
        end

        % ======================================================================
        %> @brief GetSetting gets a setting value from the config structure.
        %>
        %> @b Usage
        %>
        %> @code
        %> value = config.GetSetting('OutputDir');
        %> @endcode
        %>
        %> @param parameter [string] | The name of the parameter
        %>
        %> @retval value [any] | The value of the parameter
        % ======================================================================
        function [value] = GetSetting(parameter)
            % GetSetting gets a setting value from the config structure.
            %
            % @b Usage
            %
            % @code
            % value = config.GetSetting('OutputDir');
            % @endcode
            %
            % @param parameter [string] | The name of the parameter
            %
            % @retval value [any] | The value of the parameter
            settingsFile = fullfile(config.GetConfDir(), 'Config.mat');
            variableInfo = who('-file', settingsFile);
            if ismember(parameter, variableInfo)
                m = matfile(settingsFile);
                value = m.(parameter);
            else
                error('Parameter %s does not exist in the configuration file.');
            end
        end

        % ======================================================================
        %> @brief SetSetting sets a value in the config structure.
        %>
        %> @b Usage
        %>
        %> @code
        %> config.SetSetting('OutputDir', 'C:\\tempuser\\Desktop\\');
        %> @endcode
        %>
        %> @param parameter [string] | The name of the parameter
        %> @param value [any] | The value of the parameter
        %>
        % ======================================================================
        function [] = SetSetting(parameter, value)
            % SetSetting sets a value in the config structure.
            %
            % @b Usage
            %
            % @code
            % config.SetSetting('OutputDir', 'C:\\tempuser\\Desktop\\');
            % @endcode
            %
            % @param parameter [string] | The name of the parameter
            % @param value [any] | The value of the parameter
            %
            settingsFile = fullfile(config.GetConfDir(), 'Config.mat');
            m = matfile(settingsFile, 'Writable', true);
            m.(parameter) = value;
            config.NotifySetting(parameter, value);
        end

        % ======================================================================
        %> @brief NotifySetting the value of a setting parameter
        %>
        %> @b Usage
        %>
        %> @code
        %> config.NotifySetting('outputDir', 'C:\\tempuser\\Desktop\\');
        %> @endcode
        %>
        %> @param parameter [string] | The name of the parameter
        %> @param value [any] | The value of the parameter
        %>
        % ======================================================================
        function [] = NotifySetting(paramName, paramValue)
            % NotifySetting the value of a setting parameter
            %
            % @b Usage
            %
            % @code
            % config.NotifySetting('outputDir', 'C:\\tempuser\\Desktop\\');
            % @endcode
            %
            % @param parameter [string] | The name of the parameter
            % @param value [any] | The value of the parameter
            %
            onOffOptions = {'OFF', 'ON'};
            if islogical(paramValue)
                fprintf('--Setting [%s] to %s.\n', paramName, onOffOptions{paramValue+1});
            elseif ischar(paramValue)
                fprintf('--Setting [%s] to %s.\n', paramName, paramValue);
            elseif isnumeric(paramValue)
                fprintf('--Setting [%s] to %.2f.\n', paramName, paramValue);
            else
                error('Unsupported variable type.\n')
            end
        end

    end
end