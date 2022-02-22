% ======================================================================
%> @brief SetOpt sets parameters for running from Config.ini
%>
%> The values are recovered from MedHSIMat\\conf\\Config.ini.
%> Values are saved in an .ini format.
%>
%> @b Usage
%>
%> @code
%> SetOpt();
%> @endcode
%>
% ======================================================================
function [] = SetOpt()
% SetOpt sets parameters for running from Config.ini
%
% The values are recovered from MedHSIMat\\conf\\Config.ini.
% Values are saved in an .ini format.
%
% @b Usage
%
% @code
% SetOpt();
% @endcode
%

disp('Reading configuration file [Config.ini] ...');
inputSettingsFile = fullfile(config.GetConfDir(), 'Config.ini');

tmp = delimread(inputSettingsFile, {', '}, 'raw');
for i = 1:length(tmp.raw)

    row = tmp.raw{i};
    if ~((contains(row, '[') && contains(row, ']')) || contains(row, '#'))
        % Ignore section header and commented out lines
        parts = strsplit(row, '=');
        varName = strtrim(parts{1});
        rawValue = [];
        if length(parts) > 1
            rawValue = strtrim(parts{2});
        end

        if isempty(rawValue)
            varValue = [];
            switch varName
                case 'importDir'
                    varValue = fullfile(dataDir, 'import\');
                case 'matDir'
                    varValue = fullfile(outputDir, 'matfiles', 'hsi\');   
                case 'paramDir'
                    varValue = fullfile(dataDir, 'parameters\');
            end

        elseif strcmpi(rawValue, 'true') || strcmpi(rawValue, 'false') % logical type
            varValue = strcmpi(rawValue, 'true');
        elseif (contains(row, '{') && contains(row, '}')) % array type
            varValue = GetArray(rawValue);
        else % numeric or string type
            varValue = GetValueWithType(rawValue);
        end

        eval([varName, '=', 'varValue', ';']);
    end
end

fprintf('Data directory is set to %s.\n', dataDir);
fprintf('Import directory is set to %s.\n', importDir);
fprintf('Output directory is set to %s.\n', outputDir);
fprintf('Parameter directory is set to %s.\n', paramDir);
fprintf('Matfile directory is set to %s.\n', matDir);

clear parts row varName rawValue varValue i tmp;
settingsFile = strrep(inputSettingsFile, '.ini', '.mat');
save(settingsFile);
fprintf('\nSettings loaded from %s \n and saved in %s.\n\n', inputSettingsFile, settingsFile);

end

function [arr] = GetArray(curVal)
arr = strsplit(curVal, {'{', ', ', '}'});
arr = cellfun(@(x) GetValueWithType(strtrim(x)), arr, 'UniformOutput', 0);
end

function [updVal] = GetValueWithType(curVal)
if ~isnan(str2double(curVal)) % numeric type
    updVal = str2double(curVal);
else % string type
    updVal = curVal;
end
end