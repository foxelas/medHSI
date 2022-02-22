%======================================================================
%> @brief PlotEigenvectors plots the eigenvectors of a decomposition.
%>
%> @b Usage
%>
%> @code
%> plots.Eigenvectors(fig, coeff, xValues, pcNum);
%> @endcode
%>
%> @param fig [int] | The figure handle
%> @param eigenvec [numeric array] | The eigenvectors
%> @param xValues [numeric vector] | The x-axis values
%> @param pcNum [int] | Optional: The number of components. Default: 3
%======================================================================
function [] = PlotEigenvectors(eigenvec, xValues, pcNum, fig)
% PlotEigenvectors plots the eigenvectors of a decomposition.
%
% @b Usage
%
% @code
% plots.Eigenvectors(fig, coeff, xValues, pcNum);
% @endcode
%
% @param fig [int] | The figure handle
% @param eigenvec [numeric array] | The eigenvectors
% @param xValues [numeric vector] | The x-axis values
% @param pcNum [int] | Optional: The number of components. Default: 3
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
title('Feature Transform Vectors');
xlabel('Spectrum');
ylabel('Coefficient');
xlim([380, 780]);
legend()

plots.SavePlot(fig);

end