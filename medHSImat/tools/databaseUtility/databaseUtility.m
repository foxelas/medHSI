% ======================================================================
%>@brief databaseUtility is a class that handles interactions with the
%> database file.
%
%> The database files are saved in config::[ImportDir]\\.
%> Currently only .xlsx format is supported.
%
% For details check https://foxelas.github.io/medHSIdocs/classdatabase_utility.html
% ======================================================================
classdef databaseUtility
    methods (Static)

        % ======================================================================
        %>@brief databaseUtility.GetDataTable gets the database table.
        %>
        %> The table is recovered from
        %> config::[ImportDir]\\[Database]\\[DataInfoTableName] file and sheet
        %> 'capturedData'.
        %>
        %> @b Usage
        %>
        %> @code
        %> dataTable = databaseUtility.GetDataTable();
        %> @endcode
        %>
        % ======================================================================
        function [dataTable] = GetDataTable()
            dataTable = readtable(fullfile(config.GetSetting('ImportDir'), strcat(config.GetSetting('Database'), ...
                config.GetSetting('DataInfoTableName'))), 'Sheet', 'DataInfo');
        end

        % ======================================================================
        %>@brief databaseUtility.GetValueFromTable gets a value from the database table
        %>
        %> @b Usage
        %>
        %> @code
        %> dataTable = databaseUtility.GetValueFromTable(tab, field, id);
        %>
        %> sampleID = databaseUtility.GetValueFromTable(outRows, 'SampleID', i);
        %> @endcode
        %>
        %> @param tab [table] | A table with values
        %> @param field [char] | The target field
        %> @param id [int] | The target row index
        %>
        %> @retval value [any] | The return value
        % ======================================================================
        function [value] = GetValueFromTable(tab, field, id)
            column = tab.(field);
            if iscell(column)
                value = column{id};
            else
                value = column(id);
            end
        end

        % ======================================================================
        %>@brief databaseUtility.Query returns a query result from the database.
        %>
        %> The table is recovered from
        %> config::[ImportDir]\\[Database]\\[DataInfoTableName] file and sheet
        %> 'capturedData'.
        %>
        %> @b Usage
        %>
        %> @code
        %> [filenames, tableIds, outRows] = databaseUtility.Query(content, sampleId, captureDate, id, integrationTime, target, configuration);
        %> @endcode
        %>
        %> @param content [string or cell array] | The condition for Concent property
        %> @param sampleId [string ] | The condition for SampleID property
        %> @param captureDate [string] | The condition for CaptureDate property
        %> @param id [string] | The condition for CaptureDate property
        %> @param integrationTime [string] | The condition for IntegrationTime property
        %> @param target [string] | The condition for Target property
        %> @param configuration [string] | The condition for Configuration property
        %>
        %> @retval filenames [cell array] | The filenames of result hsi images
        %> @retval tableIds [cell array] | The table IDs of result hsi images
        %> @retval outRows [struct array] | The entire information rows of result hsi images
        % ======================================================================
        function [filenames, tableIds, outRows] = Query(varargin)
            [filenames, tableIds, outRows] = QueryInternal(varargin{:});
        end

        % ======================================================================
        %>@brief databaseUtility.GetTargetIndexes returns the target indexes based on content and target conditions.
        %>
        %> GetTargetIndexes returns target indexes and relevant rows from the databaseUtility in order to access specific types of samples.
        %>
        %> @b Usage
        %>
        %> @code
        %> [targetIDs, outRows] = databaseUtility.GetTargetIndexes(content, target);
        %>
        %> [targetIDs, outRows] = databaseUtility.GetTargetIndexes(); %all
        %>
        %> [targetIDs, outRows] = databaseUtility.GetTargetIndexes([], 'fix');
        %>
        %> [targetIDs, outRows] = databaseUtility.GetTargetIndexes({'tissue', true}, 'raw');
        %> @endcode
        %>
        %> @param content [string or cell array] | The condition for Concent property
        %> @param target [string] | The condition for Target property
        %>
        %> @retval tableIds [cell array] | The table IDs of result hsi images
        %> @retval outRows [struct array] | The entire information rows of result hsi images
        % ======================================================================
        function [targetIDs, outRows] = GetTargetIndexes(content, target)
            if nargin < 1 || isempty(content)
                content = {'tissue', true};
            end

            if nargin < 2 || isempty(target) || strcmp(target, 'all')
                target = [];
            else
                target = {target, false};
            end
            [~, targetIDs, outRows] = databaseUtility.Query(content, [], [], [], [], target, []);

        end

        % ======================================================================
        %>@brief databaseUtility.SelectDatabaseSamples returns indexes from the database table ignoring incorrect samples.
        %>
        %> It is used in @c function databaseUtility.Query
        %>
        %> YOU CAN UPDATE IT ACCORDING TO YOUR SPECIFICATIONS.
        %>
        %> @b Usage
        %>
        %> @code
        %> [setId] = databaseUtility.SelectDatabaseSamples(dataTable, setId);
        %> @endcode
        %>
        %> @param dataTable [table] | The database table
        %> @param setId [numeric array] | The currently selected indexes from the database table
        %>
        %> @retval setId [numeric array] | The currently selected indexes from the database table
        % ======================================================================
        function [setId] = SelectDatabaseSamples(dataTable, setId)
            if strcmpi(config.GetSetting('Database'), 'psl')
                setId = setId & ~contains(lower(dataTable.SampleID), 'b');
            end
        end

        % ======================================================================
        %>@brief databaseUtility.GetFileConditions returns file conditions according to the input arguments.
        %>
        %> To be used as input argments in databaseUtility.Query.
        %>
        %> @b Usage
        %>
        %> @code
        %> fileConditions = databaseUtility.GetFileConditions(content, target, id);
        %> @endcode
        %>
        %> @param content [string or cell array] | The condition for Concent property
        %> @param target [string] | The condition for Target property
        %> @param id [string] | The condition for ID property
        %>
        %> @retval fileConditions [cell array] | The file conditions
        % ======================================================================
        function [fileConditions] = GetFileConditions(content, target, id)
            if nargin < 2
                target = [];
            end
            if nargin < 3
                id = [];
            end

            if config.GetSetting('IsTest')
                fileConditions = {content, [], config.GetSetting('DataDate'), id, ...
                    config.GetSetting('IntegrationTime'), target, config.GetSetting('Configuration')};
            else
                fileConditions = {content, [], config.GetSetting('DataDate'), id, ...
                    config.GetSetting('IntegrationTime'), target, []};
            end
        end

        % ======================================================================
        %>@brief databaseUtility.GetDiagnosisTable gets the database table.
        %>
        %> The table is recovered from
        %> config::[ImportDir]\\[Database]\\[DiagnosisInfoTableName] file and sheet
        %> 'Sheet1'.
        %>
        %> @b Usage
        %>
        %> @code
        %> dataTable = databaseUtility.GetDiagnosisTable();
        %> @endcode
        %>
        % ======================================================================
        function [dataTable] = GetDiagnosisTable()
            filename = fullfile(config.GetSetting('ImportDir'), strcat(config.GetSetting('Database'), ...
                config.GetSetting('DiagnosisInfoTableName')));
            if exist(filename, 'file') > 0
                dataTable = readtable(filename, 'Sheet', 'Sheet1');
            else
                fprintf('File %s does not exist. Proceeding without it.\n', filename);
                dataTable = [];
            end
        end

        % ======================================================================
        %>@brief databaseUtility.GetDiagnosisQuery gets query result from the diagnosis table.
        %>
        %> @b Usage
        %>
        %> @code
        %> [filenames, targetIDs, outRows, diagnosis, sampleType] = databaseUtility.GetDiagnosisQuery({'tissue', true});
        %> @endcode
        %>
        %> @param condition [cell array] | The condition for the query
        %>
        %> @retval filenames [cell array] | The filenames of result hsi images
        %> @retval tableIds [cell array] | The table IDs of result hsi images
        %> @retval outRows [struct array] | The entire information rows of result hsi images
        %> @retval diagnosis [cell array] | The diagnosis of result hsi images
        %> @retval sampleType [cell array] | The sample type of result hsi images
        % ======================================================================
        function [filenames, targetIDs, outRows, diagnosis, sampleType] = GetDiagnosisQuery(condition)
            [filenames, targetIDs, outRows] = databaseUtility.Query(condition);
            dataTable = databaseUtility.GetDiagnosisTable();
            diagnosis = cell(length(filenames), 1);
            sampleType = cell(length(filenames), 1);
            for i = 1:length(filenames)
                idx = find(strcmp(dataTable.SampleID, outRows{i, 'SampleID'}));
                if ~isempty(idx)
                    diagnosis{i} = dataTable{idx, 'Diagnosis'};
                    sampleType{i} = dataTable{idx, 'Type'};
                else
                    diagnosis{i} = nan;
                    sampleType{i} = nan;
                end
            end
        end

    end
end