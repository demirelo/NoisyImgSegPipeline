function A = read3DRGB(fname) 
      %fname - name and location of 3 dimensional stack
    info = imfinfo(fname);
    num_images = numel(info);   
    for k = 1:num_images
        L = imread(fname, k, 'Info', info);
        if ndims(L)==3
            A(:,:,k) = L(:,:,1);
        else
            A(:,:,k) = L;
        end
    end
    
end

