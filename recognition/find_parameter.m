clc
clear
lambda = 0.0014:0.0001:0.0020;
sigma =  0.5:0.1:1.1;

performances=[];
for i = 1:numel(lambda)
    for j = 1:numel(sigma)
        performance = activity_recognition(lambda(i), sigma(j));
        performances = [performance; performances];
    end
end
