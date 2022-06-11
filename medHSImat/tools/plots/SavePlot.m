%======================================================================
%> @brief SavePlot saves a figure.
%>
%> @b Usage
%>
%> @code
%> config.SetSetting('PlotPath', '\temp\folder\img');
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
% config.SetSetting('PlotPath', '\temp\folder\img');
% SavePlot(fig);
% @endcode
%
% @param fig [int] | The figure handle

saveImages = config.GetSetting('SaveImages');

if (saveImages)
    figure(fig);
    figHandle = gcf;

    saveInHQ = config.GetSetting('SaveInHQ');
    saveInBW = config.GetSetting('SaveInBW');
    plotPath = config.GetSetting('PlotPath');
    cropBorders = config.GetSetting('CropBorders');
    saveEps = config.GetSetting('SaveEps');

    if (~isempty(plotPath))
        filename = strrep(plotPath, '.mat', '');

        [filepath, name, ext] = fileparts(filename);
        filepathBW = fullfile(filepath, 'bw');
        config.DirMake(filepath);
        config.DirMake(filepathBW);

        if isempty(ext)
            filename = fullfile(filepath, strcat(name, '.png'));
            ext = '.png';
        end
        exportgraphics(figHandle, filename, 'Resolution', 300, 'ContentType', 'image', 'BackgroundColor', 'white');

        if (saveEps)
            filename = strrep(filename, ext, '.eps');
            saveas(fig, filename, 'eps');
        end

        %         if (cropBorders)
        %             warning('off');
        %             export_fig(filename, '-png', '-native', '-transparent');
        %             warning('on');
        %         else
        %             if (saveInHQ)
        %                 warning('off');
        %                 export_fig(filename, '-png', '-native', '-nocrop');
        %                 %print(handle, strcat(plotPath, '.png'), '-dpng', '-r600');
        %                 warning('on');
        %             else
        %                 saveas(fig, filename, 'png');
        %             end
        %         end
        %         if (saveEps)
        %             namext = strcat(name, '.eps');
        %             if (saveInBW)
        %                 filename = fullfile(filepathBW, namext);
        %                 saveas(fig, filename, 'eps');
        %                 %                 export_fig(filename, '-eps', '-transparent', '-r900', '-gray');
        %             else
        %                 filename = fullfile(filepath, namext);
        %                 saveas(fig, filename, 'epsc');
        %                 %                 export_fig(filename, '-eps', '-transparent', '-r900', '-RGB');
        %             end
        %         end
        fprintf('Saved figure at %s.\n\n', filename);
    else
        warning('Empty plot path (config setting [plotPath]).')
    end

end

end
