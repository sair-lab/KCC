function kf = gaussian_correlation_scale_single(base, y, sigma)
	
    N = size(y,1) * size(y,2);%*size(y,3);
    for i =1:size(base,2)
        n = sum(sum(sum((base(:,i) - y).^2)))/N^2;
        k(i) = exp(-n / sigma^2 ) ;
    end
    
    kf = fft(k');
end
