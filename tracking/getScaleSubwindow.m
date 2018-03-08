function out = getScaleSubwindow(im, pos, base_target_sz, scale_factors, scale_window, scale_model_sz, hog_scale_cell_size)

%     KCC: Kernel Cross-Correlator
%     Visual Tracking Using KCC
%
%     Copyright (C) 2017 
%     Author: Wang Chen wang.chen@zoho.com Nanyang Technological University
%             Zhang Le zhang.le@adsc.com Advanced Digital Sciences Center
%
%     This file is part of KCC.
% 
%     KCC is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     KCC is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with KCC.  If not, see <http://www.gnu.org/licenses/>.
num_scales = length(scale_factors);

for s = 1:num_scales
    patch_sz = floor(base_target_sz * scale_factors(s));
    %make sure the size is not to small
    patch_sz = max(patch_sz, 2);
 
    xs = floor(pos(2)) + (1:patch_sz(2)) - floor(patch_sz(2)/2);
    ys = floor(pos(1)) + (1:patch_sz(1)) - floor(patch_sz(1)/2);
    
    %check for out-of-bounds coordinates, and set them to the values at
    %the borders
    xs(xs < 1) = 1;
    ys(ys < 1) = 1;
    xs(xs > size(im,2)) = size(im,2);
    ys(ys > size(im,1)) = size(im,1);
    
    %extract image
    im_patch = im(ys, xs, :);
    
    % resize image to model size
    im_patch_resized = mexResize(im_patch, scale_model_sz, 'auto');
    
    % extract scale features
    temp_hog = fhog(single(im_patch_resized), hog_scale_cell_size);
    temp = temp_hog(:,:,1:31);
    
    if s == 1
        out = zeros(numel(temp), num_scales, 'single');
    end
    
    % window
    out(:,s) = temp(:) * scale_window(s); 
end
