%======================================================================
%> @brief GetDiscardedPatches returns the names of patches that should be discarded from the analyis.
%> 
%> You can add values according to your protocol. 
%>
%> @b Usage
%>
%> @code
%> [discardedPatches] =  GetDiscardedPatches();
%> 
%> [discardedPatches] =  initUtility.DiscardedPatches();
%> @endcode
%>
%> @retval discardedPatches [cell array] | The ids of the discarded patches.
%======================================================================
function [discardedPatches] =  GetDiscardedPatches()   
% GetDiscardedPatches returns the names of patches that should be discarded from the analyis.
% 
% You can add values according to your protocol. 
%
% @b Usage
%
% @code
% [discardedPatches] =  GetDiscardedPatches();
% 
% [discardedPatches] =  initUtility.DiscardedPatches();
% @endcode
%
% @retval discardedPatches [cell array] | The ids of the discarded patches.

discardedPatches = {'187_patch32', '187_patch33', '199_patch24', '199_patch29', '199_patch30', '199_patch31', '199_patch32', '205_patch16', '205_patch22', ...
                '205_patch23', '205_patch24', '205_patch29', '205_patch30', '205_patch31', '205_patch32', '205_patch33', '205_patch34', '205_patch35', '205_patch37', ...
                '205_patch38', '205_patch39', '205_patch40', '205_patch41', '205_patch42', '205_patch43', '205_patch44', '205_patch47', '205_patch48', '205_patch49', ...
                '205_patch51', '205_patch52', '205_patch53', '205_patch54', '205_patch57', '205_patch58', '205_patch61', '205_patch62', '205_patch63', '205_patch66', ...
                '205_patch67', '205_patch71', '205_patch72', '205_patch73', '205_patch74', '205_patch75', '205_patch76', '205_patch77', '205_patch78', '205_patch81', ...
                '205_patch82', '205_patch83', '205_patch84', '205_patch85', '205_patch86', '205_patch87', '205_patch88', '205_patch91', '205_patch92', '205_patch93', ...
                '205_patch94', '205_patch95', '205_patch96', '205_patch97', '205_patch98', '205_patch99', '205_patch100', '205_patch101', '205_patch102', '205_patch103', ...
                '205_patch104', '205_patch105', '205_patch106', '205_patch107', '205_patch108', '205_patch109', '205_patch110', '205_patch111', '205_patch112', ...
                '205_patch113', '205_patch114', '205_patch117', '205_patch118', '205_patch119', '212_patch7', '251_patch41', '230_patch27', '227_patch1', ...
                '193_patch8', '181_patch64', '187_patch1', '160_patch8', '157_patch3', '150_patch4'};
end