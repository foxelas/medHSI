function [flag, fileS] = CheckImportData()
%CheckImportData checks hsm data and prepares the data table structure
%
%   Usage: [flag, fileS] = CheckImportData()

v = dir('D:\elena\mspi\3_skinHSI\skin samples\*.hsm');
vname = {v.name};
k = cellfun(@(x) strrep(x, '.hsm', ''), vname, 'UniformOutput', false);
fileS = struct('Filename', [], 'SampleID', [], 'Target', [], 'Content', [], ...
    'ROI', [], 'IntegrationTime', [], 'CaptureDate', [], 'IsUnfixed', [], 'IsBackside', []);
for i = 1:numel(k)
    flag = false;
    name = k{i};
    parts = strsplit(name, '_');
    fileS(i).Filename = name;
    if numel(parts) < 3
        fileS(i).SampleID = '';
        flag = true;
    else
        fileS(i).SampleID = parts{3};
    end

    if contains(name, 'black')
        fileS(i).Content = 'black';
    elseif contains(name, 'white')
        fileS(i).Content = 'white';
    elseif contains(name, 'row') || contains(name, 'raw') || contains(name, 'fix')
        fileS(i).Content = 'tissue';
    else
        fileS(i).Content = '';
    end
    if contains(name, 'fix')
        fileS(i).Target = strcat(fileS(i).SampleID, '_', 'fix');
        fileS(i).IsUnfixed = 0;
    else
        fileS(i).Target = strcat(fileS(i).SampleID, '_', 'raw');
        fileS(i).IsUnfixed = 1;
    end

    fileS(i).IsBackside = isempty(str2double(fileS(i).SampleID));

    flag = flag || contains(name, 'row');
    flag = flag || ~contains(name, 'raw') && ~contains(name, 'fix');

    if flag
        fprintf('Error at %s \n', name);
    end

    fileS(i).IntegrationTime = 618;
    fileS(i).CaptureDate = parts{1};
end

%% Check part
disp('Check Starts')
flag = true;
for i = 1:numel(k)
    if strcmp(fileS(i).Content, 'tissue')
        target = fileS(i).Target;
        if sum(strcmp({fileS.Target}, target)) > 3
            flag = false;
            fprintf('Error [More than 3 images] at %s \n', fileS(i).Filename);
        else
            b = sum(strcmp({fileS.Target}, target) & strcmp({fileS.Content}, 'black')) == 1;
            w = sum(strcmp({fileS.Target}, target) & strcmp({fileS.Content}, 'white')) == 1;
            if ~(b && w) && ~contains(target, 'b')
                flag = false;
                fprintf('Error [No white or black] at %s \n', fileS(i).Filename);
            end
        end

    end

    if strcmp(fileS(i).Content, '')
        flag = false;
        fprintf('Error [No Content] at %s \n', fileS(i).Filename);
    end
end

sampleIDs = unique({fileS.SampleID});
for i = 1:numel(sampleIDs)
    target = sampleIDs{i};
    if sum(strcmp({fileS.SampleID}, target)) < 6
        fprintf('Error [Missing fixed data] for sample %s \n', sampleIDs{i});
    end
end

if ~flag
    disp('Check failed');
else
    disp('Check passed');
    filename = config.DirMake(config.GetSetting('saveDir'), config.GetSetting('datasets'), 'last_import.xlsx');
    writetable(struct2table(fileS), filename);
    fprintf('File written in %s. \n', filename);
end
end