function [] = SavePlot(fig)
%SAVEPLOT saves the plot shown in figure fig
%
%   Usage:
%   SavePlot(2);

saveImages = GetSetting('saveImages');

if (saveImages)
    figure(fig);
    saveInHQ = GetSetting('saveInHQ');
    saveInBW = GetSetting('saveInBW');
    plotName = GetSetting('plotName');
    cropBorders = GetSetting('cropBorders');
    saveEps = GetSetting('saveEps');

    if (~isempty(plotName))
        filename = strrep(plotName, '.mat', '');

        [filepath, name, ~] = fileparts(filename);
        filepathBW = fullfile(filepath, 'bw');
        DirMake(filepath);
        DirMake(filepathBW);

        filename = fullfile(filepath, strcat(name, '.jpg'));
%         filename = strrep(filename, ' ', '_');
        if (cropBorders)
            warning('off');
            export_fig(filename, '-jpg', '-native', '-transparent');
            warning('on');
        else
            if (saveInHQ)
                warning('off');
                export_fig(filename, '-png', '-native', '-nocrop');
                %print(handle, strcat(plotName, '.png'), '-dpng', '-r600');
                warning('on');
            else
                saveas(fig, filename, 'png');
            end
        end
        if (saveEps)
            namext = strcat(name, '.eps');
            if (saveInBW)
                filename = fullfile(filepathBW, namext);
                export_fig(filename, '-eps', '-transparent', '-r900', '-gray');
            else
                filename = fullfile(filepath, namext);
                export_fig(filename, '-eps', '-transparent', '-r900', '-RGB');
            end
        end
    else
        warning('Empty plotname')
    end
end

end
