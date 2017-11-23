function [accuracy_kcc, accuracy_dtw] = show_results(filename)
    addpath('matrix2latex')
    if nargin < 1
        clear
        results = load('results.mat');
    else
        load(filename);
    end

    fusion_matrix_kcc = zeros(65);
    fusion_matrix_dtw = zeros(65);
    
    response = results.response;
    distance = results.distance;

    %% show
    for s = 1:size(response,1)
        r = reshape(response(s,:,:),65,65);
        d = reshape(distance(s,:,:),65,65);
        if nargin < 1
            figure(1);
            subplot(4,5,s);

            imagesc(r./max(r(:)))
            axis off;
            axis equal;
            grid off;
            colorbar;

            figure(2);
            subplot(4,5,s);

            imagesc(d./max(d(:)));
            axis off;
            axis equal;
            grid off;
            colorbar;
        end
        
        r(eye(size(r))~=0)=0;
        [minvalue, idr] = max(r);
        d(d==0)=inf;
        [maxvalue, idd] = min(d);

        idx_kcc = sub2ind(size(fusion_matrix_kcc), 1:65, idr);
        fusion_matrix_kcc(idx_kcc) = fusion_matrix_kcc(idx_kcc) +1;

        idx_dtw = sub2ind(size(fusion_matrix_dtw), 1:65, idd);
        fusion_matrix_dtw(idx_dtw) = fusion_matrix_dtw(idx_dtw) +1;
    end

    fusion_matrix_kcc(eye(size(fusion_matrix_kcc))~=0) = size(response,1);
    fusion_matrix_dtw(eye(size(fusion_matrix_dtw))~=0) = size(distance,1);
    if nargin < 1
        figure(3);
        subplot(121);
        imagesc(fusion_matrix_kcc./size(response,1));
        axis equal;
        axis([1,65,1,65]);
        colorbar;
        grid off;
        title('KCC');
        subplot(122);
        imagesc(fusion_matrix_dtw./size(distance,1));
        axis equal;
        colorbar;
        axis([1,65,1,65]);
        grid off;
        title('DTW');
    end
    accuracy_kcc = trace(sum_blocks(fusion_matrix_kcc, 5, 5))/sum(fusion_matrix_kcc(:));
    accuracy_dtw = trace(sum_blocks(fusion_matrix_dtw, 5, 5))/sum(fusion_matrix_dtw(:));
    
    if nargin < 1
        fprintf('accuracy kcc: %f; dtw: %f\n', accuracy_kcc, accuracy_dtw);
    end
    
    table_comparison = ...
    [diag(sum_blocks(fusion_matrix_kcc, 5, 5)./200)*100,...
     diag(sum_blocks(fusion_matrix_dtw, 5, 5)./200)*100, results.time_use/65/65*1000*1000];
    
    table_comparison = [table_comparison; mean(table_comparison)];
    
    matrix2latex(table_comparison, 'comparison_results.txt');
%     disp('Saved results table to Latex codes into comarison_results.txt')

    function out = sum_blocks(A, block_nrows, block_ncols)
        out = squeeze(sum(reshape(sum(reshape(A,block_nrows,[])),...
                            size(A,1)/block_nrows,block_ncols,[]),2));
    end
end