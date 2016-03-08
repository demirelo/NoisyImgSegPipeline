clear all; close all;
% cd('GTGen/gt_images/')
allGTFiles = dir('*_label.tif');
for ii=1:length(allGTFiles)
    gt_filename = allGTFiles(ii).name;
    I_gt = read3D(gt_filename); %label image is
    L_gt = I_gt;
    %% treat each slice separately
    if ndims(I_gt)==3
        for s=1:size(I_gt,3)
            slice = I_gt(:,:,s);
%             slice = bwlabel(slice,4);
            [gx,gy] = gradient(double(slice));
            slice((gx.^2+gy.^2)~=0) = 0;
            figure,imshow(slice)
            L_gt(:,:,s)=slice;
        end
    else
        L_gt = bwlabel(I_gt,4);
        [gx,gy] = gradient(double(L_gt));
        L_gt((gx.^2+gy.^2)~=0) = 0;
    end
    
    %% Now, check marker-controlled watershed segmentation results
    cd('../../Algorithms/mcws/results/');
    allIMCWSFiles = dir('*.tif')
    numMCWSFiles = length(allIMCWSFiles);
    seg_score = zeros(numMCWSFiles,1);
    total_seg_score = zeros(numMCWSFiles,1);
    hausdorff = zeros(numMCWSFiles,1)+Inf;
    for jj=1:length(allIMCWSFiles)
        % compute the SEG score
        L_imaris = read3D(allIMCWSFiles(jj).name);
        if ndims(L_imaris)==3
            for s=1:size(L_imaris,3)
                slice = L_imaris(:,:,s);
%                 slice = bwlabel(slice,4);
                [gx,gy] = gradient(double(slice));
                slice((gx.^2+gy.^2)~=0) = 0;
                %% just for visualization purposes
%                 slice2 = uint8(slice.*255);
%                 figure,imshow(slice2)
                L_imaris(:,:,s)=slice;
            end
        end
        
        l_gt_size = length(unique(L_gt))-1;       
        l_size = length(unique(L_imaris))-1; % exclude 0 (background)
        totalIntersection = 0;
        totalUnion = 0;
        seg_score_this  = zeros(1,l_gt_size);
        hausdorff1_this = zeros(1,l_gt_size);
        hausdorff2_this = zeros(1,l_gt_size);
        hausdorff_this  = zeros(1,l_gt_size);
        min_hausdorff = Inf;
        seg_score_sum = 0;
        found_match = 0;
        
        parfor i=1:l_gt_size
            pix_i = find(L_gt==i);
            for j=1:l_size
                pix_j = find(L_imaris==j);
                intersection = intersect(pix_i,pix_j);
                %% matching labels?
                if length(intersection)>length(pix_i)*0.5
                    seg_score_this(i) = length(intersection)/length(union(pix_i,pix_j));
                    totalIntersection = totalIntersection + length(intersection);
                    totalUnion = totalUnion + length(union(pix_i,pix_j));
                    found_match = found_match +1;
                    
                    % brute force O(n*m) Hausdorff algorithm -> too
                    % slow!
                    
                    jump1 = round(length(pix_j)/5);
                    jump2 = round(length(pix_i)/5);
                    for aj=1:jump1:length(pix_j)
                        shortest=Inf;
                        for bi=1:jump2:length(pix_i)
                            [aX, aY] = ind2sub(size(L_gt),pix_j(aj));
                            [bX, bY] = ind2sub(size(L_gt),pix_i(bi));
                            dij = sqrt( (aY-bY)^2 + (aX-bX)^2);
                            if dij<shortest
                                shortest = dij;
                            end
                        end
                        if shortest>hausdorff1_this(i)
                            hausdorff1_this(i) = shortest;
                        end
                    end
                    
                    for bi=1:jump2:length(pix_i)
                        shortest=Inf;
                        for aj=1:jump1:length(pix_j)
                            [aX, aY] = ind2sub(size(L_gt),pix_j(aj));
                            [bX, bY] = ind2sub(size(L_gt),pix_i(bi));
                            dij = sqrt( (aY-bY)^2 + (aX-bX)^2);
                            if dij<shortest
                                shortest = dij;
                            end
                        end
                        if shortest>hausdorff2_this(i)
                            hausdorff2_this(i) = shortest;
                        end
                    end
                    hausdorff_this(i) = max(hausdorff1_this(i),hausdorff2_this(i));
                    break
                end
            end
            seg_score_sum = seg_score_this(i) + seg_score_sum;
        end
        seg_score(jj) = seg_score_sum/found_match;
        hausdorff(jj) = min(hausdorff_this);
        total_seg_score(jj) = totalIntersection/totalUnion;
        
    end
    
end