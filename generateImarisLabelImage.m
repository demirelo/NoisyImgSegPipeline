%% Reads Imaris'
close all; clear all; warning('off','all');
cd('/Users/demirelo/Documents/Work/TestData/batchTest/results/text/')
allResults = dir('*.txt');

parfor i=1:length(allResults)
    filename = allResults(i).name;
    csvInfo = csvread(filename,0,0,[0,0,0,2]);
    
    allCells = csvread(filename,1,0);
    labelImage = uint16(zeros(csvInfo));
    for j=1:length(allCells)
        labelImage(allCells(j,1)+1,allCells(j,2)+1,allCells(j,3)+1)=allCells(j,4);
    end
    outputFileName = ['/Users/demirelo/Documents/Work/TestData/batchTest/results/labelImages/'...
        filename(1:length(filename)-4) '_dat.tif'];
    outputFileNameRGB = ['/Users/demirelo/Documents/Work/TestData/batchTest/results/labelImages/'...
        filename(1:length(filename)-4) '_rgb.tif'];
    if exist(outputFileName, 'file')==2
        delete(outputFileName);
    end
    if exist(outputFileNameRGB, 'file')==2
        delete(outputFileNameRGB);
    end
    for K=1:csvInfo(3)
        label = labelImage(1:csvInfo(1), 1:csvInfo(2), K);
        rgb = label2rgb(label,'jet', [0.5 0.5 0.5]);
        %     figure,imshow(rgb)
        %         label = im2bw(~label,0.95);
        imwrite(label, outputFileName, 'WriteMode', 'append','Compression','none');
        imwrite(rgb, outputFileNameRGB, 'WriteMode', 'append','Compression','none');
    end
    
end
cd('/Users/demirelo/Documents/Work/ScienceCloud/Segmentation/automatedPipeline/');
% filename = '/Users/demirelo/Documents/Work/TestData/batchTest/results/result.txt';
