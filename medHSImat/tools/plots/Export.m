%======================================================================
%> @brief Export writes an image using export_fig.
%>
%> @b Usage
%>
%> @code
%> Export(fig, plotPath);
%> @endcode
%>
%> @param fig [int] | The figure handle
%> @param plotPath [char] | The path for saving plot figures
%======================================================================
function [] = Export(fig, plotPath)

saveImages = config.GetSetting('SaveImages');

if (saveImages)
    figure(fig);
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
        export_fig(filename, '-png', '-native', '-transparent');
        
        if (saveEps)
            filename = strrep(filename, ext, '.eps');
            export_fig(filename, '-eps', '-transparent', '-r900', '-RGB');
        end
        fprintf('Exported figure at %s.\n\n', filename);
    else
        warning('Empty plot path (config setting [plotPath]).')
    end

end

end
