function out = getScaleSubwindow_v1(img, pos, target_size, search_size, rotation, scale_model_sz, hog_scale_cell_size)

% code from DSST
padding=0;
num_scales = length(search_size);
if size(img,3)>1
img= single(rgb2gray(img))/255.0;
end
for s = 1:num_scales
    tmp_sz = floor((target_size * (1 + padding))*search_size(s));
    param0 = [pos(2), pos(1), tmp_sz(2)/target_size(2), rotation/180*pi,...
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

