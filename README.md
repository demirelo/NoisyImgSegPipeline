# NoisyImgSegPipeline

This MATLAB tool generates 2D/3D synthetic images that mimic membrane-stained cells. First, it creates ground truth images (stored in GTGen/gt_images), adds noise to them (Noise/test_images) and runs selected segmentation algorithms on these test images.

## Prerequisites

This tool is tested on MATLAB R2015b. You need to have Parallel Computing Toolbox and Image Processing Toolbox.

## Getting ready
Add all the folders to your path. 
Check 'example' folder to see the ground truth, noisy and segmented image example. To quickly test the software, run `main([128 128 10], 70, 1, 3, 1)`.

If you have any questions or find issues, please let me know. 
