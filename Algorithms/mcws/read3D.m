function A = read3D(fname) 
    
    %fname - name and location of 3 dimensional stack
    info = imfinfo(fname);
    num_images = numel(info);

    for k = 1:num_images
        A(:,:,k) = imread(fname, k, 'Info', info);
    end
    
end

