# NoisyImgSegPipeline

This MATLAB tool generates 2D/3D synthetic images that mimic membrane-stained cells. First, it creates ground truth images (stored in GTGen/gt_images), adds noise to them (Noise/test_images) and runs selected segmentation algorithms on these test images.

To quickly test the software, run ' main([128 128 10], 70, 1, 3, 1) '.

If you have any questions or find issues, please let me know. 
