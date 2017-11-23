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