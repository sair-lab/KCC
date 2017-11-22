function out = getScalePatch(img, pos, target_size, search_size, rotation, scale_model_sz, hog_scale_cell_size)

% code from DSST
padding=0;
if size(img,3)>1
img= single(rgb2gray(img))/255.0;
end

tmp_sz = floor((target_size * (1 + padding))*search_size);
param0 = [pos(2), pos(1), tmp_sz(2)/target_size(2), rotation/180*pi,...
            tmp_sz(1)/target_size(2)/(target_size(1)/target_size(2)),0];
param0 = affparam2mat(param0); 
patch = warpimg(double(img), param0, target_size);
patch = fhog(single(patch), hog_scale_cell_size);
patch = patch(:,:,1:31);
out = patch(:);


