
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