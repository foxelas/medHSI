function [] = SavePlot(fig)
%SAVEPLOT saves the plot shown in figure fig
%
%   Usage:
%   SavePlot(2);

saveImages = config.GetSetting('saveImages');

if (saveImages)
    figure(fig);
    saveInHQ = config.GetSetting('saveInHQ');
    saveInBW = config.GetSetting('saveInBW');
    plotName = config.GetSetting('plotName');
    cropBorders = config.GetSetting('cropBorders');
    saveEps = config.GetSetting('saveEps');

    if (~isempty(plotName))
        filename = strrep(plotName, '.mat', '');

        [filepath, name, ~] = fileparts(filename);
        filepathBW = fullfile(filepath, 'bw');
        config.DirMake(filepath);
        config.DirMake(filepathBW);

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
                saveas(fig, filename, 'eps');
                %                 export_fig(filename, '-eps', '-transparent', '-r900', '-gray');
            else
                filename = fullfile(filepath, namext);
                saveas(fig, filename, 'epsc');
                %                 export_fig(filename, '-eps', '-transparent', '-r900', '-RGB');
            end
        end
    else
        warning('Empty plotname')
    end
end

end
