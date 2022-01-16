function [] = PlotEigenvectors(coeff, xValues, pcNum, fig)
% PlotEigenvectors plots eigenvectors of a deconmposition
%
%   Usage:
%   PlotEigenvectors(coeff, xValues, pcNum, fig)
if nargin < 3
    pcNum = 3;
end

hold on;
for i = 1:pcNum
    if i <= 5
        plot(xValues, coeff(:, i), 'DisplayName', strcat('Trans Vector', num2str(i)), 'LineWidth', 2);
    else
        plot(xValues, coeff(:, i), '--', 'DisplayName', strcat('Trans Vector', num2str(i)), 'LineWidth', 2);
    end
end
hold off;
title('Feature Transform Vectors');
xlabel('Spectrum');
ylabel('Coefficient');
xlim([380, 780]);
legend()

SavePlot(fig);

end