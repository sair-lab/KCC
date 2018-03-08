function [results] = trackerMain_otb_wangchen(p, im, bg_area, fg_area, area_resize_factor)
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

    %% INITIALIZATION
    num_frames = numel(p.img_files);
    % used for OTB-13 benchmark
    OTB_rect_positions = zeros(num_frames, 4);
	pos = p.init_pos;
    target_sz = p.target_sz;
	num_frames = numel(p.img_files);
    % patch of the target + padding
    patch_padded = getSubwindow(im, pos, p.norm_bg_area, bg_area);
    % initialize hist model
    new_pwp_model = true;
    [bg_hist, fg_hist] = updateHistModel(new_pwp_model, patch_padded, bg_area, fg_area, target_sz, p.norm_bg_area, p.n_bins, p.grayscale_sequence);
    new_pwp_model = false;
    % Hann (cosine) window
    if isToolboxAvailable('Signal Processing Toolbox')
        hann_window = single(hann(p.cf_response_size(1)) * hann(p.cf_response_size(2))');
    else
        hann_window = single(myHann(p.cf_response_size(1)) * myHann(p.cf_response_size(2))');
    end
    % gaussian-shaped desired response, centred in (1,1)
    % bandwidth proportional to target size
    output_sigma = sqrt(prod(p.norm_target_sz)) * p.output_sigma_factor / p.hog_cell_size;
    y = gaussianResponse(p.cf_response_size, output_sigma);
    yf = fft2(y);
    %% SCALE ADAPTATION INITIALIZATION
    if p.scale_adaptation
        % Code from DSST
        scale_factor = 1;
        base_target_sz = target_sz;
        scale_sigma = sqrt(p.num_scales) * p.scale_sigma_factor;
        ss = (1:p.num_scales) - ceil(p.num_scales/2);
        ys = exp(-0.5 * (ss.^2) / scale_sigma^2);
        
        ys=zeros(size(ys));
        ys(1)=1;
        ysf = ((fft(ys)));
        if mod(p.num_scales,2) == 0
            scale_window = single(hann(p.num_scales+1));
            scale_window = scale_window(2:end);
        else
            scale_window = single(hann(p.num_scales));
        end;

        ss = 1:p.num_scales;
        scale_factors = p.scale_step.^(ceil(p.num_scales/2) - ss);

        if p.scale_model_factor^2 * prod(p.norm_target_sz) > p.scale_model_max_area
            p.scale_model_factor = sqrt(p.scale_model_max_area/prod(p.norm_target_sz));
        end

        scale_model_sz = floor(p.norm_target_sz * p.scale_model_factor);
        % find maximum and minimum scales
        min_scale_factor = p.scale_step ^ ceil(log(max(5 ./ bg_area)) / log(p.scale_step));
        max_scale_factor = p.scale_step ^ floor(log(min([size(im,1) size(im,2)] ./ target_sz)) / log(p.scale_step));
    end

    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
    t_imread = 0;
    %% MAIN LOOP
    tic;
    for frame = 1:num_frames
         
        if frame>1
            tic_imread = tic;
            im = imread([p.img_path p.img_files{frame}]);
            t_imread = t_imread + toc(tic_imread);
	    %% TESTING step
            % extract patch of size bg_area and resize to norm_bg_area
            im_patch_cf = getSubwindow(im, pos, p.norm_bg_area, bg_area);
            pwp_search_area = round(p.norm_pwp_search_area / area_resize_factor);
            % extract patch of size pwp_search_area and resize to norm_pwp_search_area
            im_patch_pwp = getSubwindow(im, pos, p.norm_pwp_search_area, pwp_search_area);
            % compute feature map
            xt = getFeatureMap(im_patch_cf, p.feature_type, p.cf_response_size, p.hog_cell_size);
            % apply Hann window
            xt_windowed = bsxfun(@times, hann_window, xt);
            % compute FFT
            xtf = fft2(xt_windowed);
            % Correlation between filter and test patch gives the response
            % Solve diagonal system per pixel.
            if p.den_per_channel
                hf = hf_num ./ (hf_den + p.lambda);
            else
                hf = bsxfun(@rdivide, hf_num, sum(hf_den, 3)+p.lambda);
            end
            response_cf = ensure_real(ifft2(sum(conj(hf) .* xtf, 3)));

            % Crop square search region (in feature pixels).
            response_cf = cropFilterResponse(response_cf, ...
                floor_odd(p.norm_delta_area / p.hog_cell_size));
            if p.hog_cell_size > 1
                % Scale up to match center likelihood resolution.
                response_cf = mexResize(response_cf, p.norm_delta_area,'auto');
            end

            [likelihood_map] = getColourMap(im_patch_pwp, bg_hist, fg_hist, p.n_bins, p.grayscale_sequence);
            % (TODO) in theory it should be at 0.5 (unseen colors shoud have max entropy)
            likelihood_map(isnan(likelihood_map)) = 0;

            % each pixel of response_pwp loosely represents the likelihood that
            % the target (of size norm_target_sz) is centred on it
            response_pwp = getCenterLikelihood(likelihood_map, p.norm_target_sz);

            %% ESTIMATION
            response = mergeResponses(response_cf, response_pwp, p.merge_factor, p.merge_method);
            [row, col] = find(response == max(response(:)), 1);
            center = (1+p.norm_delta_area) / 2;
            pos = pos + ([row, col] - center) / area_resize_factor;
            rect_position = [pos([2,1]) - target_sz([2,1])/2, target_sz([2,1])];

            %% SCALE SPACE SEARCH
            if p.scale_adaptation
                current_patch = getScalePatch(im, pos, base_target_sz,  scale_factor, scale_window, scale_model_sz, p.hog_scale_cell_size);
                ksf = gaussian_correlation_scale_single(im_patch_scale, current_patch, p.scale_sigma);                    
                scale_response = abs(ifft((model_hf.*ksf)));
                [max_value, recovered_scale] = max(scale_response(:));
                
                %set the scale
                scale_factor = scale_factor / scale_factors(recovered_scale);
%                 fprintf('frame %d: recovered scale is %.2f:, current sclae factor is %.2f:\n', frame,recovered_scale,scale_factor)
               
                if scale_factor < min_scale_factor
                    scale_factor = min_scale_factor;
                elseif scale_factor > max_scale_factor
                    scale_factor = max_scale_factor;
                end
                % use new scale to update bboxes for target, filter, bg and fg models
                target_sz = round(base_target_sz * scale_factor);
                avg_dim = sum(target_sz)/2;
                bg_area = round(target_sz + avg_dim);
                if(bg_area(2)>size(im,2)),  bg_area(2)=size(im,2)-1;    end
                if(bg_area(1)>size(im,1)),  bg_area(1)=size(im,1)-1;    end

                bg_area = bg_area - mod(bg_area - target_sz, 2);
                fg_area = round(target_sz - avg_dim * p.inner_padding);
                fg_area = fg_area + mod(bg_area - fg_area, 2);
                % Compute the rectangle with (or close to) params.fixed_area and
                % same aspect ratio as the target bboxgetScaleSubwindow_v1
                area_resize_factor = sqrt(p.fixed_area/prod(bg_area));
            end

            if p.visualization_dbg==1
                mySubplot(2,1,5,1,im_patch_cf,'FG+BG','gray');
                mySubplot(2,1,5,2,likelihood_map,'obj.likelihood','parula');
                mySubplot(2,1,5,3,response_cf,'CF response','parula');
                mySubplot(2,1,5,4,response_pwp,'center likelihood','parula');
                mySubplot(2,1,5,5,response,'merged response','parula');
                drawnow
            end
        end

        %% TRAINING
        % extract patch of size bg_area and resize to norm_bg_area
        im_patch_bg = getSubwindow(im, pos, p.norm_bg_area, bg_area);
        % compute feature map, of cf_response_size
        xt = getFeatureMap(im_patch_bg, p.feature_type, p.cf_response_size, p.hog_cell_size);
        % apply Hann window
        xt = bsxfun(@times, hann_window, xt);
        % compute FFT
        xtf = fft2(xt);
        %% FILTER UPDATE
        % Compute expectations over circular shifts,
        % therefore divide by number of pixels.
		new_hf_num = bsxfun(@times, conj(yf), xtf) / prod(p.cf_response_size);
		new_hf_den = (conj(xtf) .* xtf) / prod(p.cf_response_size);

        if frame == 1
            % first frame, train with a single image
		    hf_den = new_hf_den;
		    hf_num = new_hf_num;
		else
		    % subsequent frames, update the model by linear interpolation
        	hf_den = (1 - p.learning_rate_cf) * hf_den + p.learning_rate_cf * new_hf_den;
	   	 	hf_num = (1 - p.learning_rate_cf) * hf_num + p.learning_rate_cf * new_hf_num;

            %% BG/FG MODEL UPDATE
            % patch of the target + padding
            [bg_hist, fg_hist] = updateHistModel(new_pwp_model, im_patch_bg, bg_area, fg_area, target_sz, p.norm_bg_area, p.n_bins, p.grayscale_sequence, bg_hist, fg_hist, p.learning_rate_pwp);
        end

        %% SCALE UPDATE
        if p.scale_adaptation
            im_patch_scale_frame = getScaleSubwindow_v1(im, pos, base_target_sz, scale_factors*scale_factor, scale_window, scale_model_sz, p.hog_scale_cell_size);

            if frame == 1
                im_patch_scale=im_patch_scale_frame;
            else
                im_patch_scale=(1 - p.learning_rate_scale)*im_patch_scale + p.learning_rate_scale*im_patch_scale_frame;
            end
            
            ksf = gaussian_correlation_scale_single(im_patch_scale, im_patch_scale(:,uint8(size(im_patch_scale,2)/2)), p.scale_sigma);
            model_hf = ysf'./(ksf+0.1);
        end

        % update bbox position
        if frame==1, rect_position = [pos([2,1]) - target_sz([2,1])/2, target_sz([2,1])]; end

        rect_position_padded = [pos([2,1]) - bg_area([2,1])/2, bg_area([2,1])];

        OTB_rect_positions(frame,:) = rect_position;

        if p.fout > 0,  fprintf(p.fout,'%.2f,%.2f,%.2f,%.2f\n', rect_position(1),rect_position(2),rect_position(3),rect_position(4));   end

        %% VISUALIZATION
        if p.visualization == 1
           
                figure(1)
                imshow(im)
                rectangle('Position',rect_position, 'LineWidth',2, 'EdgeColor','g');
                rectangle('Position',rect_position_padded, 'LineWidth',2, 'LineStyle','--', 'EdgeColor','b');
                drawnow
           
        end
    end
    elapsed_time = toc;
    % save data for OTB-13 benchmark
    results.type = 'rect';
    results.res = OTB_rect_positions;
    results.fps = num_frames/(elapsed_time - t_imread);
end

% Reimplementation of Hann window (in case signal processing toolbox is missing)
function H = myHann(X)
    H = .5*(1 - cos(2*pi*(0:X-1)'/(X-1)));
end

% We want odd regions so that the central pixel can be exact
function y = floor_odd(x)
    y = 2*floor((x-1) / 2) + 1;
end

function y = ensure_real(x)
    assert(norm(imag(x(:))) <= 1e-5 * norm(real(x(:))));
    y = real(x);
end