% clc
% clear
load('performances_refine_refin.mat');
plot3(performances(:,end-1), performances(:,end), performances(:,2),'.')
performances(:,[end-1,end,2])
max(performances(:,2))