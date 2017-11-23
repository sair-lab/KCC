%     KCC: Kernel Cross-Correlator
%     Activity Recognition Using KCC
%
%     Copyright (C) 2017 Wang Chen wang.chen@zoho.com
%     Nanyang Technological University
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.

function [response, output] = kcc(test, correlator)
	% Calculating the response
    % Copyright Wang Chen, Nanyang Technoglogical University
    test_fft = fft(test);
    kernel_fft = fft(gaussian_kernel(test_fft, correlator.sample_fft, correlator.sigma));
    output = abs(ifft(correlator.correlator_fft.*kernel_fft));
    response = max(output);%/sum(output);
end

