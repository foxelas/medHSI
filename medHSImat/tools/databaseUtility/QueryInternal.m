% ======================================================================
%> @brief Query returns a query result from the database.
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
function [filenames, tableIds, outRows] = QueryInternal(content, sampleId, captureDate, id, integrationTime, target, configuration)

    warning('off', 'MATLAB:table:ModifiedAndSavedVarnames');
    dataTable = databaseUtility.GetDataTable();

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

    if nargin < 1 
        content = [];
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
        setId = setId & ismember(dataTable.Configuration, configuration);
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

    %            if ~isempty(captureDate)
    %                setId = setId & ismember(dataTable.CaptureDate, str2double(captureDate));
    %            end

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