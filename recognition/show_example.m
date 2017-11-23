load('data.mat');
%% show
sequence = 100:200;
subject = 1;
activity = 1;
samples =1;


example1 = data{1, 1, 1}(sequence, :)';
example2 = data{1, 8, 1}(sequence, :)';
example3 = data{1, 9, 1}(sequence, :)';


figure(1);
subplot(211);
grid off;
imagesc(example1);
axis equal;
title ('The color map of activity ''ReSt'' from the first subject')
colormap('jet')
axis([1,100,1,25]);
colorbar;

subplot(212);
grid off;
imagesc(example2);
axis equal;
title ('The color map of activity ''TuRi'' from the first subject')
colormap('jet')
axis([1,100,1,25]);
colorbar;

figure (2)
subplot(311);
grid off;
imagesc(example1);
axis equal;
title ('The color map of activity ''ReSt'' from the first subject')
colormap('jet')
axis([1,100,1,25]);
colorbar;

subplot(312);
grid off;
imagesc(example2);
axis equal;
title ('The color map of activity ''TuRi'' from the first subject')
colormap('jet')
axis([1,100,1,25]);
colorbar;

subplot(313);
grid off;
imagesc(example3);
axis equal;
title ('The color map of activity ''Up'' from the first subject')
colormap('jet')
axis([1,100,1,25]);
colorbar;