function [desiredResponse, x0, y0] = getDesiredResponse(saliency_map, bg_area, target_sz, p)
% GETDESIREDRESPONSE is a wrapper for getGaussian, that computes the (object-centered) desired response

% If the saliency patch is empty, use a patch centered desired response only for one frame
if(sum(sum(saliency_map))==0)
    p.gaussianType = 'bboxCentered';
    [desiredResponse, ~, ~] = getGaussian(saliency_map, bg_area, target_sz, p);
    x0 = 0;
    y0 = 0;
    p.gaussianType = 'objectCentered';
else
    [desiredResponse, x0, y0] = getGaussian(saliency_map, bg_area, target_sz, p);
end

end