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

function results = activity_recognition(lambda, sigma)
    close all
    load('data.mat');

    if nargin < 2
        lambda = 0.0015;
        sigma = 1;
    end
    
    disp('running recognition...')
    sequence = 76:125; % remove first 75 unstable points, cannot be larger, or Index exceeds matrix dimensions
    time_kcc = zeros(13,1);
    time_dtw = zeros(13,1);

    %% examples
    for subject = 1:size(data,1)
        for activity = 1:size(data, 2)
            for samples = 1:5%size(data, 3) %only one subject has the 6th sample in only one activity
                if isempty(data{subject, activity, samples})
                    continue;
                end

                train = data{subject, activity, samples}(sequence, :);
                tic
                correlator = kcc_train(train, lambda, sigma);
                time_kcc(activity) = time_kcc(activity) + toc;

                for activity_test = 1:size(data, 2)
                    for samples_test = 1:5%size(data, 3) %only one subject has the 6th sample in only one activity
                        if isempty(data{subject, activity_test, samples_test})
                            continue;
                        end

                        test = data{subject, activity_test, samples_test}(sequence, :);

                        tic
                        response(subject, 5*(activity-1)+ samples, 5*(activity_test-1)+ samples_test) = kcc(test, correlator);
                        time_kcc(activity_test) = time_kcc(activity_test) + toc;

                        tic
                        distance(subject, 5*(activity-1)+ samples, 5*(activity_test-1)+ samples_test) = dtw(train', test');
                        time_dtw(activity_test) = time_dtw(activity_test) + toc;
                    end
                end
            end    
        end
    end
    
    time_use = [time_kcc, time_dtw];
    filename = 'results.mat';
    save(filename, 'response', 'distance', 'time_use');
    disp('Saved results to results.mat')
    [accuracy_kcc, accuracy_dtw] = show_results();
    results = [accuracy_dtw, accuracy_kcc, sum(time_dtw), sum(time_kcc), sigma, lambda];
    fprintf('accuracy_dtw: %f; accuracy_kcc: %f; time_dtw: %f s, time_kcc: %f s; sigma: %f lambda: %f\n', ...
        results(1),  results(2), results(3), results(4), results(5), results(6));
    disp('Done.')
end
