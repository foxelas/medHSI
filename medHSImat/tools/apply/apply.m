% ======================================================================
%> @brief apply is a utility class for applying functions en mass and independently to different data samples
%
%> Functions using apply are applied on the currently selected dataset,
%> unless mentioned otherwise. The dataset name is recovered from
%> config.GetSetting('Dataset').
%>
%
% For details check https://foxelas.github.io/medHSIdocs/classapply.html
% ======================================================================
classdef apply
    methods (Static)
        % ======================================================================
        %> @brief apply.ToEach applies a function on each of the data samples in the dataset.
        %>
        %> The target function should have arguments in the format of (hsIm,
        %> , ...), where hsIm is an instance of class 'hsi'. The targetID
        %> is saved for figure saving purposes in config::[FileName].
        %>
        %> @b Usage
        %>
        %> @code
        %> apply.ToEach(@CustomKmeans, 5);
        %> @endcode
        %>
        %> @param funcHandle [function handle] | Handle of the target function to be applied
        %> @param varargin [cell array] | The arguments necessary for the target function
        %>
        %> @retval varargout [cell array] | The return values of the target function
        % ======================================================================
        function [varargout] = ToEach(funcHandle, varargin)

            if nargin < 2
                varargin = {};
            end

            [~, targetIDs] = commonUtility.DatasetInfo();

            for i = 1:length(targetIDs)

                %% load HSI from .mat file
                targetID = targetIDs{i};
                [hsIm, labelInfo] = hsiUtility.LoadHsiAndLabel(targetID);

                config.SetSetting('FileName', targetID);

                %% Change to Relevant Script
                if nargout(funcHandle) > 0
                    varargout{:} = funcHandle(hsIm, labelInfo, varargin{:});
                else
                    funcHandle(hsIm, labelInfo, varargin{:});
                    varargout{:} = {};
                end
            end
        end

        % ======================================================================
        %> @brief apply.DisableFigures applies a script while suppressing figure production and saving.
        %>
        %> @b Usage
        %>
        %> @code
        %> apply.DisableFigures(@apply.SuperpixelAnalysis);
        %> @endcode
        %>
        %> @param funcHandle [function handle] | Handle of the target function to be applied
        %> @param varargin [cell array] | The arguments necessary for the target function
        %>
        %> @retval varargout [cell array] | The return values of the target function
        % ======================================================================
        function [varargout] = DisableFigures(funcHandle, varargin)

            warning('off', 'all');
            showFigures = config.GetSetting('ShowFigures');
            saveImages = config.GetSetting('SaveImages');

            config.SetSetting('ShowFigures', false);
            config.SetSetting('SaveImages', false);
            warning('on', 'all');

            if nargout(funcHandle) > 0
                varargout{:} = funcHandle(varargin{:});
            else
                funcHandle(varargin{:});
                varargout{:} = {};
            end

            warning('off', 'all');
            config.SetSetting('SaveImages', saveImages);
            config.SetSetting('ShowFigures', showFigures);
            warning('on', 'all');
        end

        % ======================================================================
        %> @brief apply.DisableSaveFigures applies a script while suppressing figure saving.
        %>
        %> @b Usage
        %>
        %> @code
        %> apply.DisableSaveFigures(@apply.SuperpixelAnalysis);
        %> @endcode
        %>
        %> @param funcHandle [function handle] | Handle of the target function to be applied
        %> @param varargin [cell array] | The arguments necessary for the target function
        %>
        %> @retval varargout [cell array] | The return values of the target function
        % ======================================================================
        function [varargout] = DisableSaveFigures(funcHandle, varargin)

            warning('off', 'all');
            saveImages = config.GetSetting('SaveImages');
            config.SetSetting('SaveImages', false);
            warning('on', 'all');
            if nargout(funcHandle) > 0
                varargout{:} = funcHandle(varargin{:});
            else
                funcHandle(varargin{:});
                varargout{:} = {};
            end

            warning('off', 'all');
            config.SetSetting('SaveImages', saveImages);
            warning('on', 'all');
        end

        % ======================================================================
        %> @brief apply.RowFunc applies a function on each row of the input.
        %>
        %> Is the input data is an hsi instance, then the pixels that
        %> belong to the foreground mask are considered.
        %>
        %> @b Usage
        %>
        %> @code
        %> meanVals = apply.RowFunc(@mean, X);
        %>
        %> meanVals = apply.RowFunc(@mean, hsIm);
        %> @endcode
        %>
        %> @param funcHandle [function handle] | Handle of the target function to be applied
        %> @param X [numeric array] | The input data as an array, where each
        %> row is a feature vector.
        %> @param varargin [cell array] | The arguments necessary for the target function
        %>
        %> @retval result [cell array] | The return values of the target function
        % ======================================================================
        function [result] = RowFunc(funcHandle, X, varargin)
 
            if hsi.IsHsi(X)
                X = X.GetMaskedPixels();
            end

            rows = size(X, 1);
            result = cell(rows, 1);
            for i = 1:rows
                if nargout(funcHandle) > 0
                    if nargin(funcHandle) > 1
                        varargout{:} = funcHandle(X(rows, :), varargin{:});
                    else
                        varargout{:} = funcHandle(X(rows, :));
                    end
                else
                    if nargin(funcHandle) > 1
                        funcHandle(X(rows, :), varargin{:});
                    else
                        funcHandle(X(rows, :));
                    end
                    varargout{:} = {};
                end
                result{i} = varargout;
            end

            if isnumeric(result{1})
                result = cell2mat(result);
            end
        end
    end
end