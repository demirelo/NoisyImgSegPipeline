function I = GTGen(imsize, numCells, batchSize, cellRoughness, writeRGB)
%GTGEN generates 2D/3D synthetic (ground truth) images for membrane-based
% segmentation purposes. The generated synthetic cells may go from top to
% bottom, tube-like. They are not necessarily 'closed' surfaces.
%
% IN:
%   imsize        - size of the to-be generated image: exp: [512 512]. If
%                   length(imsize)==1, then a square image is produced.
%                   X and Y dimensions must be a multiple of 32.
%   numCells      - approximate number of cells to be generated in the image
%   batchSize     - the number of GT images to be generated
%   cellRoughness -  defines how rough the cells will be. Only 3D, Integer-value
%   writeRGB      - if 1, an RGB image will be written as well.
%
% OUT:
%   I             - generated image.
%
% Copyright: Omer Demirel (omerddd@gmail.com), University of Zurich, 2015

cellRoughness = ceil(cellRoughness);
cd gt_images
%% image generation
for i=1:batchSize
    % file output name
    outputFileName = ['gt_' int2str(numCells) 'cells_num' num2str(i) '_label.mat' ];
    
    % randomly place the seeds for regions
    centr_rand = ceil(rand(numCells,2)*imsize(1));
    BW = zeros(imsize);
    % in 3D, put the seeds in the same location in all 2D slices
    if length(imsize)==3
        for slice=1:imsize(3)
            L = BW(:,:,slice);
            for seed=1:length(centr_rand)
                L(centr_rand(seed,1),centr_rand(seed,2)) = 255; % plant the seeds
                BW(:,:,slice) = L;
            end
        end
    else
        for seed=1:length(centr_rand)
            BW(centr_rand(seed,1),centr_rand(seed,2)) = 255; % plant the seeds
        end
    end
    
    %to do: while background still white, repeat
    if length(imsize)==2
        I = bwlabel(BW);
        while (any(I(:) == 0))
            x = randi(imsize(1)/4)+1;
            y = x;
            I = nlfilter(I, [y x], @myFilterFunc);
            % uncomment for a simple 2D visualization of the progress
            %             imshow(label2rgb(I))
        end
        I = label2rgb(I);
        I = rgb2gray(I);
        I = imgradient(I);
        I = bwmorph(I, 'skel', 1);
        I = uint8(I.*255);
        if exist(outputFileName, 'file')==2
            delete(outputFileName);
        end
        imwrite(I, outputFileName, 'WriteMode', 'append');
    else %3D
        I = bwlabeln(BW);
        % first, finish the first slice
        while (any(I(:,:,1) == 0))
            x = randi(imsize(1)/32)+1;
            r = (rand())/10;
            if rand()>0.5
                x = ceil(x*(1+r));
            else
                x = ceil(x*(1-r));
            end
            y = x;
            L = nlfilter(I(:, :, 1), [y x], @myFilterFunc);
            I(:, :, 1) = L;
        end
        % change the cell volume by changing the cell countour in following
        % slices. The frequency of this change is defined by cellRoughness.
        for K=2:length(I(1, 1, :))
            if  mod(K,cellRoughness)==0
                r = (rand())/10;
                if rand()>0.5
                    x = ceil(x*(1+r));
                else
                    x = ceil(x*(1-r));
                end
                y = x;
                while (any(I(:,:,K) == 0))
                    L = nlfilter(L, [y x], @myFilterFunc);
                    I(:, :, K) = L;
                end
            else
                I(:, :, K) = L;
            end
        end
        for K=1:size(I,3)
            L = I(:,:,K);
            L(L==0)=1;
            [gx,gy] = gradient(double(L));
            L((gx.^2+gy.^2)~=0) = 0;
            I(:,:,K) = L;
        end
        %         I = uint8(I.*255);
        if exist(outputFileName, 'file')==2
            delete(outputFileName);
        end
        save(outputFileName,'I');
        outputFileName = ['gt_' int2str(numCells) 'cells_num' num2str(i) '_label.tif' ];
        for K=1:size(I,3)
            imwrite(I(:, :, K), outputFileName, 'WriteMode', 'append');
        end
        %% write an RGB image
        if writeRGB==1
            outputFileName2 = ['gt_' int2str(numCells) 'cells_num' num2str(i) '_rgb.tif' ];
            if exist(outputFileName2, 'file')==2
                delete(outputFileName2);
            end
            for K=1:size(I,3)
                L = label2rgb(I(:,:,K),'jet', [0.5 0.5 0.5]);
                
                imwrite(L, outputFileName2, 'WriteMode', 'append');
            end
        end
    end
end
end