function [ Ld2 ] = imwatershed( I , h  )
%IMWATERSHED computes the marker-controlled watershed
%
% IN: 
%   I - image to be segmented
%   h - scalar value for h-minima transform
mask = imextendedmin(I,h);
% figure(), imshowpair(I,mask,'blend')

D2 = imimposemin(I,mask);
Ld2 = watershed(D2);

end

