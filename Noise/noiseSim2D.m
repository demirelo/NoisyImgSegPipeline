function [noisy2DSlice,filename] = noiseSim2D(I, gt_filename, choice, level, isWriting)

%NOISESIM2D takes a 2D ground truth data and adds different noises to it
%
% Example:
%   noiseSim2D(I, gt_filename,'cloudy',level, 1)
%
% IN:
%   I           - 2D image or a 2D slice in a 3D stack
%   gt_filename - the full path to the GT image that will be noised.
%   choice      - type of noise either 'cloudy' or 'normal'
%   level       - level of specke and salt & pepper noise
%   isWriting   - if 1, the noisy 2D image will be written
%
% Copyright: Omer Demirel (omerddd@gmail.com), University of Zurich, 2015

if ~strcmp(choice,'cloudy') && ~strcmp(choice,'normal')
    error('Unknown CHOICE of noise')
elseif level<=0
    error('noise level must be >0')
end

I = imcomplement(I);
speckle = level * 0.3;
sp = speckle/2;

% normal noise is always added
L_skel = imnoise(I,'speckle',speckle);
specklename = int8(speckle/0.3);
L_sp = imnoise(L_skel, 'salt & pepper', sp);
L_sp = imgaussfilt(L_sp, 1.0);
L_skel = imgaussfilt(L_skel, 1.2);
L_sp = L_skel+L_sp;

% add cloud noise as well
if strcmp(choice,'cloudy') 
    
    % cloudy background noise
    h = 0.8;
    grayImage = noiseonf(size(I,1), h);
    grayImage8bit = uint8(255 * mat2gray(grayImage));
    assignin('base','L_sp',L_sp);
    L_sp = L_sp + grayImage8bit;
    filename = [gt_filename(4:length(gt_filename)-4) '_' int2str(specklename) 'sp_cloudy.tif'];
else
    filename = [gt_filename(4:length(gt_filename)-4) '_' int2str(specklename) 'sp.tif'];
end
if isWriting==1    
    if exist(filename, 'file')==2
        delete(filename);
    end
    imwrite(imadjust(L_sp),filename);
else
    noisy2DSlice = imadjust(L_sp);
end