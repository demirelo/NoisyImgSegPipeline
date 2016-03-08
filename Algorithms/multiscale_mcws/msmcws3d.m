function merged_label = msmcws3d(I,sigmaVec,h)
%MSMCWS3D runs a multiscale watershed segmentation algorithm
% In twoscale marker-controlled watershed segmentation (MSMCW), we generate two watershed
% segmentations with different Gaussian kernel widths. 2nd level, which has
% more segmented regions than the 1st one, is used to correct the borders
% in the first scale. This means that MSMCW has to get the number of regions
% correct in the first scale.
%
% Example:
%   msmcws3d(I,[0.8 0.5],2)
%
% IN:
%   I        - noisy image to be segmented
%   sigmaVec - a vector of Gaussian kernel widths used for blurring. It defines the number of scales and 
%              the sigma value in each scale in watershed segmentation. As we go deeper down the scales,
%              sigma value becomes smaller. Thus, sigmaVec(1)>sigmaVec(2)>..
%   h        - a scalar used for h-minima transform
%
% OUT:
%   merged_label - merged watershed result
% Copyright: Omer Demirel (omerddd@gmail.com), University of Zurich, 2015


sizeI = size(I);
numScales = length(sigmaVec);
%% Create blurred images at different scales
if length(sizeI)==3
    numZstacks = sizeI(3);
    blurred_scales = zeros(numScales,sizeI(1),sizeI(2),numZstacks);
    for i=1:numScales
        newI = imgaussfilt3(I,sigmaVec(i));
        blurred_scales(i,:,:,:) = newI;
    end
else
    %     figure, imshow(I);
    blurred_scales = zeros(length(sigmaVec),sizeI(1),sizeI(2));
    for i=1:length(sigmaVec)
        newI = imgaussfilt(I,sigmaVec(i));
        blurred_scales(i,:,:) = newI;
%         figure,imshow(newI)
    end
    
end
%% Apply watershed in each scale
for i=1:numScales-1
    if i==1
        if length(sizeI)==3
            newI = squeeze(blurred_scales(i,:,:,:));
        else
            newI = squeeze(blurred_scales(i,:,:));
        end
        % compute the marker-controlled watershed
        label_i = imwatershed(newI,h);
        %             figure,imshow3Dfull(label_i);
    else
        label_i = merged_label;
    end
    % uncomment for visualization of 2D images
%     rgb = label2rgb(label_i, 'jet', [.5 .5 .5]);
%     figure, imshowpair(originalI,rgb,'montage');
    % next scale
    j=i+1;
    if length(sizeI)==3
        newI = squeeze(blurred_scales(j,:,:,:));
    else
        newI = squeeze(blurred_scales(j,:,:));
    end
    % compute the marker-controlled watershed
    label_j = imwatershed(newI,h);
    % uncomment for visualization of 2D images
%     rgb = label2rgb(label_j, 'jet', [.5 .5 .5]);
%     figure, imshowpair(originalI,rgb,'montage');
    
    %% find overlapping regions at both scales
%     max_label_j = max(label_j(:));
    max_label_i = max(label_i(:));
    
    for thisLabel_i = 1:max_label_i
        ind_i = find(label_i==thisLabel_i);
        allPix_j = label_j(ind_i);
        overlapped_idx_j = unique(allPix_j);
        for id = 1:length(overlapped_idx_j)
            ind_j = find(label_j==overlapped_idx_j(id));
            C = intersect(ind_j,ind_i);
            % if at least 50% of a label in j belongs to a label in i,
            % label in i gets the whole label j.
            if length(C)*2>length(ind_j) 
                label_i(ind_j) = thisLabel_i;
            end
        end
    end
    %% draw borders
    if length(sizeI)==3
        [gx,gy,gz] = gradient(double(label_i));
        label_i((gx.^2+gy.^2+gz.^2)~=0) = 0;
        merged_label = label_i;
%         figure,imshow3Dfull(merged_label_i),title('Merged');
    else
        [gx,gy] = gradient(double(label_i));
        label_i((gx.^2+gy.^2)~=0) = 0;
        merged_label = label_i;
%         rgb = label2rgb(merged_label_i,'jet', [.5 .5 .5]);
%         figure, imshowpair(originalI,rgb,'MONTAGE'),title('Merged');
    end
    
end
