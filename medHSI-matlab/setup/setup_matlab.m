%% Downloads and sets dependencies
%% Run from nside setup folder 

dependenciesDir = fullfile('..', 'toolbox');
if ~exist(dependenciesDir, 'dir')
    mkdir(dependenciesDir);
    addpath(dependenciesDir);
end
mkdir('downloads');
addpath('downloads');

disp('Setup started.')

%% Download dependencies 
fd = fopen('dependencies_matlab.md','r');
formatSpec = ['- %s %s %s'];
contents = textscan(fd, formatSpec,Inf, 'Delimiter',{'[details](','), [download](',')'});
fclose(fd); 

if ~isempty(contents)
    n = length(contents{1,1});
end

disp('Download started...')

for i = 1:n
    url = contents{1, 3}{i};
    name = strrep(lower(contents{1, 1}{i}), ' ', '');
    filepath = fullfile('downloads', strcat(name, '.zip'));
    websave(filepath, url);
    filenames = unzip(filepath, fullfile(dependenciesDir, name));
    for j = 1:numel(filenames)
        folder = fileparts(filenames{j}); 
        addpath(genpath(folder));
    end
end 
disp('Download finished.')

[status,msg,msgID] = rmdir('downloads', 's');


%% Add all new directories to the path
cd('../')
dirList = dir(pwd);

for i = 1:numel(dirList)
    if contains(dirList(i).name, 'tools') || contains(dirList(i).name, 'toolbox')  ...
            || contains(dirList(i).name, 'src') 
        subdirList = dir(fullfile(dirList(i).folder, dirList(i).name));
        for j = 1:numel(subdirList)
            if ~contains(dirList(i).name, '.') 
                addpath(genpath(fullfile(subdirList(j).folder, subdirList(j).name)))
                fullfile(subdirList(j).folder, subdirList(j).name)
            end
        end
    end
end
