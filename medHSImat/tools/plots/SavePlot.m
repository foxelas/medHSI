%======================================================================
%> @brief SavePlot saves a figure.
%>
%> @b Usage
%>
%> @code
%> config.SetSetting('plotPath', '\temp\folder\img');
%> SavePlot(fig);
%> @endcode
%>
%> @param fig [int] | The figure handle
%======================================================================
function [] = SavePlot(fig)
% SavePlot saves a figure.
%
% @b Usage
%
% @code
% config.SetSetting('plotPath', '\temp\folder\img');
% SavePlot(fig);
% @endcode
%
% @param fig [int] | The figure handle

saveImages = config.GetSetting('saveImages');

if (saveImages)
    figure(fig);
    saveInHQ = config.GetSetting('saveInHQ');
    saveInBW = config.GetSetting('saveInBW');
    plotPath = config.GetSetting('plotPath');
    cropBorders = config.GetSetting('cropBorders');
    saveEps = config.GetSetting('saveEps');

    if (~isempty(plotPath))
        filename = strrep(plotPath, '.mat', '');

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
                %print(handle, strcat(plotPath, '.png'), '-dpng', '-r600');
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
        fprintf('Saved figure at %s.\n\n', filename);
    else
        warning('Empty plot path (config setting [plotPath]).')
    end

end

end
