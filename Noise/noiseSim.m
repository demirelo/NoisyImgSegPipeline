function I = noiseSim(gt_filename, choice, level)

%NOISESIM takes a 2D/3D ground truth data and adds different noises
%
% Example:
%   noiseSim(gt_filename,'cloudy',level)
%
% IN:
%   gt_filename - the full path to the GT image that will be noised.
%   choice      - type of noise either 'cloudy' or 'normal'
%   level       - level of specke and salt & pepper noise
%
% Copyright: Omer Demirel (omerddd@gmail.com), University of Zurich, 2015


if ~strcmp(choice,'cloudy') && ~strcmp(choice,'normal')
    error('Unknown CHOICE of noise')
elseif level<=0
    error('noise level must be >0')
end
I = read3D(gt_filename);
% I_struct = load(gt_filename);
% I = cell2mat(struct2cell(I_struct));
% % I = uint8(255 * mat2gray(I));
assignin('base','I',I)
% always add speckle and salt & pepper noise
if ndims(I)==3
    for s=1:size(I,3)
%         figure, imshow(I(:,:,s));
        L = I(:,:,s);
        [L_noisy,filename] = noiseSim2D(L,gt_filename,choice,level,0);
        I(:,:,s) = L_noisy;
        if mod(s,5)==0
            disp(['Noising...' num2str(s*100/size(I,3)) '% done']);
        end   
        cd ../../Noise/test_images
        imwrite(I(:,:,s), filename, 'WriteMode', 'append');
    end    
else
    cd ../../Noise/test_images
    noiseSim2D(I,gt_filename,choice,level,1);
end
