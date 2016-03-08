function [ Ld2 ] = imwatershed( I , h  )
%IMWATERSHED Summary of this function goes here
%   Detailed explanation goes here
mask = imextendedmin(I,h);
% figure(), imshowpair(I,mask,'blend')

D2 = imimposemin(I,mask);
% figure(), imshowpair(I,D2,'blend')
% D2 = (1-mask) .* I;
Ld2 = watershed(D2);

end

