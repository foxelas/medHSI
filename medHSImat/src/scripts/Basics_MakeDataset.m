function [] = Basics_MakeDataset(baseDataset)

if nargin < 1
    baseDataset = 'pslCore';
end

%%%%%%%%%%%%%%%%%%%%% Prepare Data %%%%%%%%%%%%%%%%%%%%%

config.SetOpt();
config.SetSetting('isTest', false);
config.SetSetting('database', 'psl');
config.SetSetting('dataset', baseDataset);
config.SetSetting('normalization', 'byPixel');

CheckImportData();

%Disable normalization check during data reading
config.SetSetting('disableNormalizationCheck', true);
%Do no use mask for unispectrum calculation
config.SetSetting('useCustomMask', false);

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
