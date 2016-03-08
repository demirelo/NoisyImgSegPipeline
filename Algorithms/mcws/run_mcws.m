% Dr. Omer Demirel - 05/2015,
% Marker-controlled Watershed segmentation, 
% University of Zurich. oemer.demirel@uzh.ch
%
% This is the simple, single scale watershed segmentation 
function [] = run_mcws(filename,sigma,h)
I = read3D(filename);
label_i = mcws3d(I,sigma,h);

warning('off','all')
% visualize results
sizeI = size(I);
if length(sizeI)==3
    [gx,gy,gz] = gradient(double(label_i));
    label_i((gx.^2+gy.^2+gz.^2)~=0) = 0;
    label = label_i;
%     figure,imshow3Dfull(label),title('Merged');
else
    [gx,gy] = gradient(double(label_i));
    label_i((gx.^2+gy.^2)~=0) = 0;
    label = label_i;
    rgb = label2rgb(label,'jet', [.5 .5 .5]);
%     figure, imshowpair(I,rgb,'MONTAGE'),title('Merged');
end

% write results
%% black & white TIF output
label_i(label_i~=0)=10000;
% label_i = im2bw(label_i, 0.95);
outputFileName = ['single_ws_' filename '_s' num2str(sigma) '_h' num2str(h) '.tif'];
if exist(outputFileName, 'file')==2
    delete(outputFileName);
end
cd('../../Algorithms/mcws/results')
for K=1:length(label_i(1, 1, :))
    label = label_i(:, :, K);
    label = im2bw(~label,0.95);
    imwrite(label, outputFileName, 'WriteMode', 'append','Compression','none');
end
cd('../../../Noise/test_images')
end

% %% colored TIF output
% outputFileName = 'img_stack_full_colored.tif';
% for K=1:length(label_i(1, 1, :))
%     label = label_i(:, :, K);
%     imwrite(label, outputFileName, 'WriteMode', 'append','Compression','none');
% end