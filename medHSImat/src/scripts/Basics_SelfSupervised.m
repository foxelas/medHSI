function [] = Basics_SelfSupervised()
clc;
option = 'sam';

if strcmpi(option, 'sam')

    %% SAM
    experiment = strcat('SAM segmentation-BCC&MCC');
    Basics_Init(experiment);

    apply.ToEach(@SAMAnalysis);    
    GetMontagetCollection('predLabel');


elseif strcmpi(option, 'superpca')

    %% SuperPCA
    pixelNum = 20;
    pcNum = 5;

    %% Manual
    experiment = strcat('SuperPCA-Manual', date());
    Basics_Init(experiment);

    isManual = true;
    apply.ToEach(@SuperpixelAnalysis, isManual, pixelNum, pcNum);

    GetMontagetCollection('eigenvectors');
    GetMontagetCollection('superpixel_mask');
    GetMontagetCollection('pc1');
    GetMontagetCollection('pc2');
    GetMontagetCollection('pc3');

    %% From SuperPCA package
    experiment = strcat('SuperPCA', date());
    Basics_Init(experiment);

    isManual = false;
    apply.ToEach(@SuperpixelAnalysis, isManual, pixelNum, pcNum);

    GetMontagetCollection('eigenvectors');
    GetMontagetCollection('superpixel_mask');
    GetMontagetCollection('pc1');
    GetMontagetCollection('pc2');
    GetMontagetCollection('pc3');

elseif strcmpi(option, 'msuperpca')

    %% Multiscale SuperPCA
    experiment = strcat('MultiscaleSuperPCA-Manual', date());
    Basics_Init(experiment);
    
    pixelNumArray = floor(50*sqrt(2).^[-2:2]);
    apply.ToEach(@MultiscaleSuperpixelAnalysis, pixelNumArray);

else
    fprintf('Unsupported [option] value.\n');
end

end

function GetMontagetCollection(target)
path = commonUtility.GetFilename('output', config.GetSetting('saveFolder'), '');
fprintf('Montage from path %s.\n', path);
criteria = struct('TargetDir', 'subfolders', 'TargetName', target);
plots.MontageFolderContents(1, [], criteria, [], [800, 800]);
end
