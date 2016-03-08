%% cleans up the workspace and removes files in the directories
clear all; clc;
cd GTGen/gt_images
delete *.tif *.mat
cd ../../Noise/test_images
delete *.tif
cd ../../Algorithms/mcws/results
delete *.tif
cd ../../multiscale_mcws/results
delete *.tif
cd ../../../
