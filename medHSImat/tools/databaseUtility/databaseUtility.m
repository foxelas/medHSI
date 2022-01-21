classdef databaseUtility
    methods (Static)

        %% Contents
        %
        %   Static:
        %         [dataTable] = GetdatabaseUtility()
        %         [filenames, tableIds, outRows] = Query(content, sampleId, captureDate, id, integrationTime, target, configuration)
        %         [targetIDs, outRows] = GetTargetIndexes(content, target)
        %         [filename, tableId, outRow] = GetFilename(content, sampleId, captureDate, id, integrationTime, target, configuration, specialTarget)
        %         [outR] = CheckOutRow(inR, content, sampleId, captureDate, id, integrationTime, target, configuration, specialTarget)
        %         [setId] = SelectDatabaseSamples(dataTable, setId)
        %         [fileConditions] = GetFileConditions(content, target, id)

        function [dataTable] = GetdatabaseUtility()

            %% GetdatabaseUtility returns the db structure as a table
            %
            %   Usage:
            %   dataTable = GetdatabaseUtility()
            dataTable = readtable(fullfile(config.GetSetting('importDir'), strcat(config.GetSetting('database'), ...
                config.GetSetting('dataInfoTableName'))), 'Sheet', 'capturedData');
        end

        function [filenames, tableIds, outRows] = Query(content, sampleId, captureDate, id, integrationTime, target, configuration)

            %% Query Gets the respective filename for configuration value
            %   arguments are received in the order of
            %     'configuration' [light source]
            %     'content' [type of captured object]
            %     'integrationTime' [value of integration time]
            %     'target' [details about captured object]
            %     'dataDate' [captureDate]
            %     'id' [number value for id ]
            %
            %   Usage:
            %   [filenames, tableIds, outRows] = Query(content, sampleId, captureDate, id, integrationTime, target, configuration)

            warning('off', 'MATLAB:table:ModifiedAndSavedVarnames');
            dataTable = databaseUtility.GetdatabaseUtility();

            if nargin < 7
                configuration = [];
            end
            if nargin < 6
                target = [];
            end
            if nargin < 5
                integrationTime = [];
            end
            if nargin < 4
                id = [];
            end
            if nargin < 3
                captureDate = [];
            end

            if nargin < 2
                sampleId = [];
            end

            function [keyValue, isMatch] = GetCondition(value)
                if iscell(value)
                    isMatch = value{2};
                    keyValue = value{1};
                else
                    isMatch = true;
                    keyValue = value;
                end
            end

            setId = true(numel(dataTable.ID), 1);

            if ~isempty(configuration)
                setId = setId & ismember(dataTable.configuration, configuration);
            end

            if ~isempty(content)
                [content, isMatchContent] = GetCondition(content);
                if isMatchContent %whether content is exact match or just contains
                    setId = setId & ismember(dataTable.Content, content);
                else
                    setId = setId & contains(lower(dataTable.Content), lower(content));
                end
            end

            if ~isempty(integrationTime)
                setId = setId & ismember(dataTable.IntegrationTime, integrationTime);
            end

            if ~isempty(target)
                [target, isMatchTarget] = GetCondition(target);
                if isMatchTarget
                    setId = setId & ismember(dataTable.Target, target);
                else
                    setId = setId & contains(lower(dataTable.Target), lower(target));
                end
            end

            if ~isempty(captureDate)
                setId = setId & ismember(dataTable.CaptureDate, str2double(captureDate));
            end

            if ~isempty(id)
                setId = setId & ismember(dataTable.ID, id);
            end

            if ~isempty(sampleId)
                setId = setId & ismember(dataTable.SampleID, sampleId);
            end

            setId = databaseUtility.SelectDatabaseSamples(dataTable, setId);

            outRows = dataTable(setId, :);
            filenames = outRows.Filename;
            tableIds = outRows.ID;

            % Sort by sampleID
            [outRows, sortId] = sortrows(outRows, {'SampleID', 'IsUnfixed'}, {'ascend', 'descend'});
            filenames = filenames(sortId);
            tableIds = tableIds(sortId);
        end

        function [targetIDs, outRows] = GetTargetIndexes(content, target)
            %GetTargetIndexes returns target indexes and relevant rows from the databaseUtility in
            %order to access specific categories of *tissue* samples.
            %
            %   Usage:
            %   [targetIDs, outRows] = GetTargetIndexes(); %all
            %   [targetIDs, outRows] = GetTargetIndexes([], 'fix'); %fix
            %   [targetIDs, outRows] = GetTargetIndexes({'tissue', true}, 'raw'); %raw

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

        function [filename, tableId, outRow] = GetFilename(content, sampleId, captureDate, id, integrationTime, target, configuration, specialTarget)

            %% GetFilename Gets the respective filename for configuration value
            %   arguments are received in the order of
            %     'content' [type of captured object]
            %     'sampleId' [number value for sample id]
            %     'captureDate' [captureDate for object]
            %     'id' [number value for id ]
            %     'integrationTime' [value of integration time]
            %     'target' [details about captured object]
            %     'configuration' [light source]
            %
            %   Usage:
            %   [filename, tableId, outRow] = GetFilename(content, sampleId,
            %   captureDate, id, integrationTime, target, configuration, specialTarget)

            if nargin < 8
                specialTarget = '';
            end

            if ~isempty(integrationTime)
                initialIntegrationTime = integrationTime;
            end

            [~, ~, outRow] = databaseUtility.Query(content, sampleId, captureDate, id, integrationTime, target, configuration);
            outRow = databaseUtility.CheckOutRow(outRow, content, sampleId, captureDate, id, integrationTime, target, configuration, specialTarget);

            filename = outRow.Filename{1};
            tableId = outRow.ID;

            if outRow.IntegrationTime ~= initialIntegrationTime
                setSetting('integrationTime', integrationTime);
            end

            if nargin >= 3 && ~isempty(integrationTime) && integrationTime ~= outRow.IntegrationTime
                warning('Integration time in the settings and in the retrieved file differs.');
                %     setSetting('integrationTime', integrationTime);
            end

        end

        function [outR] = CheckOutRow(inR, content, sampleId, captureDate, id, integrationTime, target, configuration, specialTarget)
            outR = inR;
            if isempty(inR.ID) && ~isempty(specialTarget)
                if strcmp(specialTarget, 'black')
                    configuration = 'noLight';
                end
                [~, ~, outR] = databaseUtility.Query(content, sampleId, captureDate, id, integrationTime, target, configuration);
                if isempty(outR.ID) && strcmp(specialTarget, 'black')
                    [~, ~, outR] = databaseUtility.Query('capOn', sampleId, '20210107', id, integrationTime, target, configuration);
                end
            end

            if numel(outR.ID) > 1
                warning('Taking the first from multiple rows that satisfy the conditions.');
                outR = outR(1, :);
            end
        end

        function [setId] = SelectDatabaseSamples(dataTable, setId)
            %SelectDatabaseSamples from DataInfo table in order to ignore incorrect
            %samples inside Query.m
            %
            %   Usage:
            %   [setId] = SelectDatabaseSamples(dataTable, setId)
            if strcmpi(config.GetSetting('database'), 'psl')
                setId = setId & ~contains(lower(dataTable.SampleID), 'b');
            end
        end

        function [fileConditions] = GetFileConditions(content, target, id)

            %% GETFILECONDITIONS returns the conditions necessary for finding the
            %%filename of the file to be read
            %
            %   Usage:
            %   fileConditions = GetFileConditions(content, target)

            if nargin < 2
                target = [];
            end
            if nargin < 3
                id = [];
            end

            if config.GetSetting('isTest')
                fileConditions = {content, [], config.GetSetting('dataDate'), id, ...
                    config.GetSetting('integrationTime'), target, config.GetSetting('configuration')};
            else
                fileConditions = {content, [], config.GetSetting('dataDate'), id, ...
                    config.GetSetting('integrationTime'), target, []};
            end
        end
    end
end