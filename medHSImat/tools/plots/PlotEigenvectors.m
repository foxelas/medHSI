%======================================================================
%> @brief PlotEigenvectors plots the eigenvectors of a decomposition.
%>
%> @b Usage
%>
%> @code
%> Eigenvectors(coeff, xValues, pcNum, [], fig);
%>
%> PlotEigenvectors(eigenvec, xValues, pcNum, figTitle, fig);
%> @endcode
%>
%> @param eigenvec [numeric array] | The eigenvectors
%> @param xValues [numeric vector] | The x-axis values
%> @param pcNum [int] | Optional: The number of components. Default: 3.
%> @param figTitle [char] | The figure title
%> @param fig [int] | The figure handle
%======================================================================
function [] = PlotEigenvectors(eigenvec, xValues, pcNum, figTitle, fig)

if nargin < 3
    pcNum = 3;
end

symbol = {'-', ':', '-.', '--', 'o'};
hold on;
for i = 1:pcNum
    if i <= 5
        plot(xValues, eigenvec(:, i), symbol{i}, 'DisplayName', strcat('Trans Vector', num2str(i)), 'LineWidth', 2);
    else
        plot(xValues, eigenvec(:, i), '--', 'DisplayName', strcat('Trans Vector', num2str(i)), 'LineWidth', 2);
    end
end
hold off;
xlabel('Spectrum');
ylabel('Coefficient');
xlim([380, 780]);
legend()

if nargin > 3
    if ~isempty(figTitle)
        title(figTtitle)
    end
end

if nargin > 4
    plots.SavePlot(fig);
end

end