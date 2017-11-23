function kf = gaussian_kernel(xf, yf, sigma)
	% Calculating the gaussian kernel vertor
    % Copyright Wang Chen, Nanyang Technoglogical University
    
	N = numel(xf);
	xx = xf(:)' * xf(:) / N;
	yy = yf(:)' * yf(:) / N;
	xy = mean((ifft(xf .* conj(yf))),2);
	kf = exp(-1 / sigma^2 * (xx + yy - 2 * xy) / N);
end

