function [] = SetOpt()
%     SETOPT sets parameters for running from conf/config.ini
%
%     Usage:
%     SetOpt()

disp('Reading configuration file [config.ini] ...');

currentDir = pwd; 
projectName = 'medHSI';
parts = strsplit(currentDir, 'medHSI');
inputSettingsFile = fullfile(parts{1}, projectName, 'conf', 'config.ini');

tmp = delimread(inputSettingsFile, {', '}, 'raw');
options = struct();
for i = 1:length(tmp.raw)
    
    row = tmp.raw{i};
    if ~((contains(row, '[') && contains(row, ']')) || contains(row, '#')) 
        % Ignore section header and commented out lines   
        parts = strsplit(row, '=');
        varName = strrep(parts{1}, ' ', '');
        rawValue = []; 
        if length(parts) > 1 
            rawValue = strrep(parts{2}, ' ', '');
        end 
        
        if isempty(rawValue)
            varValue = []; 
            switch varName
                case 'inputDir'
                    varValue = fullfile(parentDir, 'input\');
                case 'importDir'
                    varValue = fullfile(inputDir, 'import\');
                case 'outputDir'
                    varValue = fullfile(parentDir, 'output\');
                case 'dataDir'
                    varValue = parentDataDir;
                case 'matDir'
                    varValue = fullfile(parentDataDir, 'matfiles', 'hsi\');
                case 'saveDir'
                    varValue = outputDir;
                case 'inDir'
                    varValue = parentDataDir;
            end
            
        elseif strcmpi(rawValue, 'true') || strcmpi(rawValue, 'false') % logical type
            varValue = strcmp(rawValue, '1');
        elseif (contains(row, '{') && contains(row, '}')) % array type
            varValue = GetArray(rawValue);
        else % numeric or string type 
            varValue = GetValueWithType(rawValue);
        end
        
        eval([varName, '=', 'varValue', ';']);        
    end 
end

fprintf('Data directory is set to %s.\n', dataDir);
fprintf('Save directory is set to %s.\n', saveDir);

clear parts row varName rawValue varValue i currentDir projectName tmp;
settingsFile = strrep(inputSettingsFile, '.ini', '.mat');
save(settingsFile);
fprintf('Settings loaded from %s and saved in %s.\n', inputSettingsFile, settingsFile);

end

function [arr] = GetArray(curVal)
arr = strsplit(curVal, {'{', ', ', '}'});
arr = cellfun(@(x) GetValueWithType(strrep(x, ' ', '')), arr, 'UniformOutput', 0);
end

function [updVal] = GetValueWithType(curVal)
    if ~isnan(str2double(curVal)) % numeric type
        updVal = str2double(curVal);
    else % string type  
        updVal = curVal;
    end
end