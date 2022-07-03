%======================================================================
%> @brief SavePlot saves a figure.
%>
%> The plot name should be set beforehand in config::[PlotPath].
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
        fprintf('Saved figure at %s.\n\n', filename);
    else
        warning('Empty plot path (config setting [plotPath]).')
    end

end

end
