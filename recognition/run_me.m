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

data_conversion; % convert database to compatible format

activity_recognition; % run recognition demo and show results

%% you may also run show_example after running data_conversion to visulize the signals.
show_example

%% Example to use KCC similarity
lambda = 0.0015;
sigma = 1;

correlator = kcc_train(example1, lambda, sigma);

similarity_12 = kcc(example2, correlator)
similarity_13 = kcc(example3, correlator)