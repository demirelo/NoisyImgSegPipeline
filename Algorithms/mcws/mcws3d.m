% Dr. Omer Demirel - 05/2015,
% Marker-controlled Watershed segmentation,
% University of Zurich. oemer.demirel@uzh.ch
%
function merged_label = mcws3d(I,sigma,h)
% I: Input image
% sigma: Gaussian kernel width
% h: A scalar used for h-minima transform
%
% merged_label: Merged watershed result

sizeI = size(I);
%% Create blurred images at different scales
if length(sizeI)==3
    %     figure,imshow3Dfull(I);
    newI = imgaussfilt3(I,sigma);
else
    newI = imgaussfilt(I,sigma);
    %         figure,imshow(newI)
end
%% compute the marker-controlled watershed
label_i = imwatershed(newI,h);

% uncomment for visualization of 2D images
%     rgb = label2rgb(label_j, 'jet', [.5 .5 .5]);
%     figure, imshowpair(originalI,rgb,'montage');

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

