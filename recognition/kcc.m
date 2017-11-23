function [response, output] = kcc(test, correlator)
	% Calculating the response
    % Copyright Wang Chen, Nanyang Technoglogical University
    test_fft = fft(test);
    kernel_fft = fft(gaussian_kernel(test_fft, correlator.sample_fft, correlator.sigma));
    output = abs(ifft(correlator.correlator_fft.*kernel_fft));
    response = max(output);%/sum(output);
end

