function results = run_KCC(seq, res_path, bSaveImage)
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

    %% Read params.txt
    params = readParams('params.txt');
    params.img_files = seq.s_frames;
    params.img_path = '';

    im = imread(params.img_files{1});
    % grayscale sequence? --> use 1D instead of 3D histograms
    if(size(im,3)==1)
        params.grayscale_sequence = true;
    end

    region = seq.init_rect;

    if(numel(region)==8)
        % polygon format (VOT14, VOT15)
        [cx, cy, w, h] = getAxisAlignedBB(region);
    else % rectangle format (WuCVPR13)
        x = region(1);
        y = region(2);
        w = region(3);
        h = region(4);
        cx = x+w/2;
        cy = y+h/2;
    end

    % init_pos is the centre of the initial bounding box
    params.init_pos = [cy cx];
    params.target_sz = round([h w]);

    [params, bg_area, fg_area, area_resize_factor] = initializeAllAreas(im, params);

	% in runTracker we do not output anything because it is just for debug
	params.fout = -1;

	% start the actual tracking
	results = trackerMain_otb_wangchen(params, im, bg_area, fg_area, area_resize_factor);
    fclose('all');
end