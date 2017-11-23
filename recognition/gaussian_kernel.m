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


function kf = gaussian_kernel(xf, yf, sigma)
	% Calculating the gaussian kernel vertor
    % Copyright Wang Chen, Nanyang Technoglogical University
    
	N = numel(xf);
	xx = xf(:)' * xf(:) / N;
	yy = yf(:)' * yf(:) / N;
	xy = mean((ifft(xf .* conj(yf))),2);
	kf = exp(-1 / sigma^2 * (xx + yy - 2 * xy) / N);
end

