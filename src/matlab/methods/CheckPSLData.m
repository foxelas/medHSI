function [flag, fileS] = CheckPSLData()
%CheckPSLData checks hsm data and prepares the data table structure
%
%   Usage: [flag, fileS] = CheckPSLData()

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
            b = sum(strcmp({fileS.Target}, target) & strcmp({fileS.Content}, 'black')) == 1;
            w = sum(strcmp({fileS.Target}, target) & strcmp({fileS.Content}, 'white')) == 1;
            if ~(b && w) 
                flag = false;
                fprintf('Error at %s \n', fileS(i).Filename);
            end       
        end 

        if strcmp(fileS(i).Content, '')
            flag = false; 
            fprintf('Error at %s \n', fileS(i).Filename);
        end  
    end 

    if ~flag
        disp('Check failed');
    else 
        disp('Check passed');
        writetable(struct2table(fileS), 'new_import.xlsx')
    end 
end 