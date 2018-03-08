function out = getScaleSubwindow_v1(img, pos, target_size, search_size, scale_window, scale_model_sz, hog_scale_cell_size)
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
padding=0;
num_scales = length(search_size);
if size(img,3)>1
img= single(rgb2gray(img))/255.0;
end
for s = 1:num_scales
    tmp_sz = floor((target_size * (1 + padding))*search_size(s));
    param0 = [pos(2), pos(1), tmp_sz(2)/target_size(2), 0,...
                tmp_sz(1)/target_size(2)/(target_size(1)/target_size(2)),0];
    param0 = affparam2mat(param0); 
    patch = warpimg(double(img), param0, target_size);
    patch = fhog(single(patch), hog_scale_cell_size);
    patch = patch(:,:,1:31);
    
    if s == 1
        out = zeros(numel(patch), num_scales, 'single');
    end
    
    % window
    out(:,s) = patch(:);%* scale_window(s);
end

