classdef metrics
    methods (Static)

        %% GoodnessOfFit returns the Goodness Of Fit criterion
        %
        %   Usage:
        %   gfc = GoodnessOfFit(reconstructed, measured)
        function gfc = GoodnessOfFit(reconstructed, measured)
            if size(reconstructed) ~= size(measured)
                reconstructed = reconstructed';
            end
            gfc = abs(reconstructed*measured') / (sqrt(sum(reconstructed.^2)) * sqrt(sum(measured.^2)));
        end

        %% Nmse returns the Normalized Mean Square Error
        %
        %   Usage:
        %   nmse = Nmse(reconstructed, measured)
        function nmse = Nmse(reconstructed, measured)
            nmse = (measured - reconstructed) * (measured - reconstructed)' / (measured * reconstructed');
        end

        %% RMSE returns the Root Mean Square Error
        %
        %   Usage:
        %   rmse = Rmse(reconstructed, measured)
        function rmse = Rmse(reconstructed, measured)
            N = size(measured, 2);
            rmse = sqrt(((measured - reconstructed) * (measured - reconstructed)')/N);
        end

    end
end