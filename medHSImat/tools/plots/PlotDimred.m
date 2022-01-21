function [] = PlotDimred(method, dimredResult, w, redHsis)
% PlotDimred plots all relevant plots for dimension reduction
%
%   Input arguments:
%   method: 'pca', 'rica'
%   dimredResult: cell array with the output of dimension reduction
%   w: the original dimensions before reduction
%   redHsis: reduced data recovered to original spatial dimensions
%
%
%   Usage:
%   PlotDimred('pca', {coeff, scores, explained, latent}, 420:730,
%   {[20,20];[30,30]});
%

close all;
saveto = GetSetting('saveDir');

coeff = dimredResult{1};
scores = dimredResult{2};

%% PCA
if strcmp(method, 'pca')
    explained = dimredResult{3};
    latent = dimredResult{4};

    figure(1);
    plot(explained(1:10));
    title('Explained Variance');
    xlabel('Order');
    ylabel('Explained Variance');
    SetSetting('plotName', fullfile(saveto, 'explained'));
    SavePlot(1);

    figure(2);
    plot(latent(1:10));
    title('Eigenvalues');
    xlabel('Order');
    ylabel('Eigenvalue');
    SetSetting('plotName', fullfile(saveto, 'eigenvalues'));
    SavePlot(2);

    SetSetting('plotName', fullfile(saveto, 'eigenvectors3'));
    plots(3, @PlotEigenvectors, coeff, w, 3);
    SetSetting('plotName', fullfile(saveto, 'eigenvectors10'));
    plots(4, @PlotEigenvectors, coeff, w, 10);

    subimageName = 'Principal Component';
end

%% RICA
if strcmp(method, 'rica')
    objective = dimredResult{3};
    iteration = 1:numel(objective);

    figure(1);
    plot(iteration, objective);
    xlabel('iterations');
    ylabel('Objection function value');
    title('Minimization progress')
    SetSetting('plotName', fullfile(saveto, 'minimize'));
    SavePlot(1);

    SetSetting('plotName', fullfile(saveto, 'transform_vectors3'));
    plots(3, @PlotEigenvectors, coeff, w, 3);
    SetSetting('plotName', fullfile(saveto, 'transform_vectors310'));
    plots(4, @PlotEigenvectors, coeff, w, 10);

    subimageName = 'Feature';
end


for i = 1:numel(sizeProd)
    redHsi = redHsis{i};

    %% Plot components
    sampleName = strcat('Tissue', num2str(i));
    SetSetting('plotName', fullfile(saveto, strcat('img', num2str(i), '_pcs')));
    plots(4, @PlotSubimageMontage, redHsi, sampleName, 6);

    name = strcat(subimageName, '1', '_', sampleName);
    figure(6);
    imagesc(redHsi(:, :, 1));
    title(name);
    colorbar
    SetSetting('plotName', fullfile(saveto, strrep(lower(name), '_', '_')));
    SavePlot(6);

    name = strcat(subimageName, '2', '_', sampleName);
    figure(7);
    imagesc(redHsi(:, :, 2));
    title(name);
    colorbar
    SetSetting('plotName', fullfile(saveto, strrep(lower(name), '_', '_')));
    SavePlot(7);

    name = strcat(subimageName, '3', '_', sampleName);
    figure(8);
    imagesc(redHsi(:, :, 3));
    title(name);
    colorbar
    SetSetting('plotName', fullfile(saveto, strrep(lower(name), '_', '_')));
    SavePlot(8);

end

end