function correlator = kcc_train(sample, lambda, sigma)
	% Training the correlator based on one sample
    % Copyright Wang Chen, Nanyang Technoglogical University
    if nargin < 3
        sigma = 0.3;
    end
    if nargin < 2
        lambda = 0.1;
    end
    
    correlator.sigma = sigma;
    target_fft = ones(size(sample,1),1);
    correlator.sample_fft = fft(sample);
    kernel_fft = fft(gaussian_kernel(correlator.sample_fft, correlator.sample_fft, correlator.sigma));
    correlator.correlator_fft = target_fft./(kernel_fft + lambda);
end

