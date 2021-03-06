function [update] = symmetric_optical_flow_registration(...
    moving, fixed, movingDeformed, fixedDeformed, ...
    transformationModel, multiModal,varargin)
% OPTICAL_FLOW_REGISTRATION Estimates a displacement field using optical flow
%
% [update] = symmetric_optical_flow_registration(...
%     moving, fixed, movingDeformed, fixedDeformed, ...
%     transformationModel, multiModal,varargin)
%
% INPUT ARGUMENTS
% moving                        - Moving iamge
% fixed                         - Fixed image
% movingDeformed                - Deformed moving iamge
% fixedDeformed                 - Deformed fixed image
% transformationModel           - Transformation model for estimating the
%                                 displacement field
%                                 'translation', 'affine', 'non-rigid'
% multiModal                    - Multi-modal registration
%
% OPTIONAL INPUT ARGUMENTS
% 'numberOfChannels'        - Number of channels to use in when computing
%                             the entropy (based on channel coding). This
%                             is only relevant if multiModal is set to
%                             true.
%                             Default value is 8
%
% OUTPUT ARGUMENTS
% update
%  displacementUpdateForward    - Estimated update field from fixed to
%                                 moving deformed
%  displacementUpdateBackward   - Estimated update field from moving to
%                                 fixed deformed
% (only if transformation model is set to translation or affine)
%  transformationMatrixForward  - Estimate transformation matrix from fixed 
%                                 to moving deformed
%  transformationMatrixBackward - Estimate transformation matrix from moving 
%                                 to fixed deformed

% Copyright (c) 2012
% danne.forsberg@outlook.com
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

%% Setup default parameters
% Only valid for multi-modal registration
numberOfChannels = 8;

% Overwrites default parameter
for k=1:2:length(varargin)
    eval([varargin{k},'=varargin{',int2str(k+1),'};']);
end;

%%
dims = ndims(moving);

if strcmp(transformationModel,'non-rigid')
    switch dims
        case 2
            [update.displacementForward] = ...
                demons2d(movingDeformed,fixed,...
                'multiModal',multiModal,...
                'numberOfChannels',numberOfChannels,...
                'method','symmetric');
            [update.displacementBackward] = ...
                demons2d(fixedDeformed,moving,...
                'multiModal',multiModal,...
                'numberOfChannels',numberOfChannels,...
                'method','symmetric');
        case 3
            [update.displacementForward] = ...
                demons3d(movingDeformed,fixed,...
                'multiModal',multiModal,...
                'numberOfChannels',numberOfChannels,...
                'method','symmetric');
            [update.displacementBackward] = ...
                demons3d(fixedDeformed,moving,...
                'multiModal',multiModal,...
                'numberOfChannels',numberOfChannels,...
                'method','symmetric');
    end
else
    switch dims
        case 2
            [update.transformationMatrixForward] = ...
                optical_flow_linear_registration2d(...
                movingDeformed,fixed,...
                'transformationModel',transformationModel,...
                'multiModal',multiModal,...
                'numberOfChannels',numberOfChannels);
            [update.transformationMatrixBackward] = ...
                optical_flow_linear_registration2d(...
                fixedDeformed,moving,...
                'transformationModel',transformationModel,...
                'multiModal',multiModal,...
                'numberOfChannels',numberOfChannels);
        case 3
            [update.transformationMatrixForward] = ...
                optical_flow_linear_registration3d(...
                movingDeformed,fixed,...
                'transformationModel',transformationModel,...
                'multiModal',multiModal,...
                'numberOfChannels',numberOfChannels);
            [update.transformationMatrixBackward] = ...
                optical_flow_linear_registration3d(...
                fixedDeformed,moving,...
                'transformationModel',transformationModel,...
                'multiModal',multiModal,...
                'numberOfChannels',numberOfChannels);
    end
end
