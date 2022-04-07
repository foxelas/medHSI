% ======================================================================
%> @brief SetOpt sets parameters for running from config.ini
%>
%> The values are recovered from MedHSIMat\\conf\\config.ini.
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
% SetOpt sets parameters for running from config.ini
%
% The values are recovered from MedHSIMat\\conf\\config.ini.
% Values are saved in an .ini format.
%
% @b Usage
%
% @code
% SetOpt();
% @endcode
%

disp('Reading configuration file [config.ini] ...');
inputSettingsFile = fullfile(config.GetConfDir(), 'config.ini');

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

fprintf('Data directory is set to %s.\n', DataDir);
fprintf('Import directory is set to %s.\n', ImportDir);
fprintf('Output directory is set to %s.\n', OutputDir);
fprintf('Parameter directory is set to %s.\n', ParamDir);
fprintf('Matfile directory is set to %s.\n', MatDir);

clear parts row varName rawValue varValue i tmp;
settingsFile = strrep(inputSettingsFile, '.ini', '.mat');
save(settingsFile);
fprintf('\nSettings loaded from \n%s\nand saved in \n%s.\n\n', inputSettingsFile, settingsFile);

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