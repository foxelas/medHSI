function [] = Basics_MakeDataset(baseDataset)

if nargin < 1
    baseDataset = 'pslCore';
end

%%%%%%%%%%%%%%%%%%%%% Prepare Data %%%%%%%%%%%%%%%%%%%%%

config.SetOpt();
config.SetSetting('IsTest', false);
config.SetSetting('Database', 'psl');
config.SetSetting('Dataset', baseDataset);
config.SetSetting('Normalization', 'byPixel');

CheckImportData();

%Disable normalization check during data reading
config.SetSetting('DisableNormalizationCheck', true);
%Do no use mask for unispectrum calculation
config.SetSetting('UseCustomMask', false);

if strcmpi(baseDataset, 'pslCore')
    dbSelection = {'tissue', true};
    hsiUtility.PrepareDataset(baseDataset, dbSelection);
end

if strcmpi(baseDataset, 'pslCoreAugmented')
    augDataset = 'pslCoreAugmented';
    trainUtility.Augment('pslCore', augDataset, 'set1');
end


if strcmpi(baseDataset, 'pslRaw')
    dbSelection = {'tissue', true};
    target = {'raw', false};
    hsiUtility.PrepareDataset(baseDataset, dbSelection, true, target);
end

if strcmpi(baseDataset, 'pslFix')
    dbSelection = {'tissue', true};
    target = {'fix', false};
    hsiUtility.PrepareDataset(baseDataset, dbSelection, true, target);
end

hsiUtility.ExportH5Dataset();
end
