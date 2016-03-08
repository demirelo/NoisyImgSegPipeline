function A = read3D(fname)

%READ3D reads a 3D image stack
%
% IN:
%   fname - name and location of the 3D stack
%
% Copyright: Omer Demirel (omerddd@gmail.com), University of Zurich, 2015

info = imfinfo(fname);
num_images = numel(info);

for k = 1:num_images
    A(:,:,k) = imread(fname, k, 'Info', info);
end

end

