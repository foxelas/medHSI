function [] = Basics_SelfSupervised()

option = 'msuperpca'; 

if strcmpi(option, 'sam')
    %% SAM 
    experiment = strcat('SAM segmentation-BCC');
    Basics_Init(experiment);

    apply.ToEach(@SAMAnalysis);

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

    apply.ToEach(@MultiscaleSuperpixelAnalysis);

else 
    fprintf('Unsupported [option] value.\n');
end

end

function GetMontagetCollection(target)
    criteria = struct('TargetDir', 'subfolders', 'TargetName', target);
    plots.MontageFolderContents(1, [], criteria);
    criteria = struct('TargetDir', 'subfolders', 'TargetName', target, 'TargetType', 'fix');
    plots.MontageFolderContents(2, [], criteria, strcat(target, ' for fix'));
    criteria = struct('TargetDir', 'subfolders', 'TargetName', target, 'TargetType', 'raw');
    plots.MontageFolderContents(3, [], criteria, strcat(target, ' for ex-vivo'));
end
