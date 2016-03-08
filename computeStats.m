close all; clear all;
cd('/Users/demirelo/Documents/Work/TestData/batchTest/ImarisBatchScripts/results/')
allFiles = dir('*.data');
numFiles = length(allFiles);
for f=1:numFiles
    data = int32(csvread(allFiles(f).name));
    x_max = max(data(:,1)); y_max = max(data(:,2)); z_max = max(data(:,3));
    l_max = max(data(:,4));
    L = zeros(x_max+1,y_max+1,z_max+1);
    I = zeros(x_max+1,y_max+1,z_max+1);
    for row=1:length(data)
        L(data(row,1)+1,data(row,2)+1,data(row,3)+1)= data(row,4);
        I(data(row,1)+1,data(row,2)+1,data(row,3)+1)= data(row,5);
    end
    clearvars data
    %% compute region statistics
    stats = regionprops(L,'Area','Centroid','BoundingBox');
    
    %% get cell volumes and centroids;
    cellVolumes = [stats.Area]';
    cellCentroids = reshape([stats.Centroid],[3, l_max]);
    
    
    %% find membrane voxels of each label TODO: use neighborhoodND
    cellMembranes = zeros(l_max,max(cellVolumes)); % keeps the indices
    counter = 0;
    for label=1:l_max
        thisLabelVoxels = find(L==label);
        [X,Y,Z] = ind2sub(size(L),thisLabelVoxels);
        for i=1:length(X)
            if X(i)==1 || X(i)==x_max || Y(i)==1 || Y(i)==y_max || Z(i)==1 || Z(i)==z_max
                counter = counter +1 ;
                cellMembranes(label,counter)=thisLabelVoxels(i);
                continue
            end
            % check all 26 neighbors in 3D
            if X(i)<x_max && X(i)>1 && Y(i)<y_max && Y(i)>1 && Z(i)<z_max && Z(i)>1
                if      ... // Z-1
                        L(X(i)-1,Y(i)+1,Z(i)-1)~=label || L(X(i)  ,Y(i)+1,Z(i)-1)~=label || L(X(i)+1,Y(i)+1,Z(i)-1)~=label || ...
                        L(X(i)-1,Y(i)  ,Z(i)-1)~=label || L(X(i)  ,Y(i)  ,Z(i)-1)~=label || L(X(i)+1,Y(i)  ,Z(i)-1)~=label || ...
                        L(X(i)-1,Y(i)-1,Z(i)-1)~=label || L(X(i)  ,Y(i)-1,Z(i)-1)~=label || L(X(i)+1,Y(i)-1,Z(i)-1)~=label || ...
                        ... // Z
                        L(X(i)-1,Y(i)+1,Z(i)  )~=label || L(X(i)  ,Y(i)+1,Z(i)  )~=label || L(X(i)+1,Y(i)+1,Z(i)  )~=label || ...
                        L(X(i)-1,Y(i)  ,Z(i)  )~=label ||                                   L(X(i)+1,Y(i)  ,Z(i)  )~=label || ...
                        L(X(i)-1,Y(i)-1,Z(i)  )~=label || L(X(i)  ,Y(i)-1,Z(i)  )~=label || L(X(i)+1,Y(i)-1,Z(i)  )~=label || ...
                        ... // Z+1
                        L(X(i)-1,Y(i)+1,Z(i)+1)~=label || L(X(i)  ,Y(i)+1,Z(i)+1)~=label || L(X(i)+1,Y(i)+1,Z(i)+1)~=label || ...
                        L(X(i)-1,Y(i)  ,Z(i)+1)~=label || L(X(i)  ,Y(i)  ,Z(i)+1)~=label || L(X(i)+1,Y(i)  ,Z(i)+1)~=label || ...
                        L(X(i)-1,Y(i)-1,Z(i)+1)~=label || L(X(i)  ,Y(i)-1,Z(i)+1)~=label || L(X(i)+1,Y(i)-1,Z(i)+1)~=label
                    
                    counter = counter +1 ;
                    cellMembranes(label,counter)=thisLabelVoxels(i);
                    continue
                end
            end
        end
        counter = 0;
    end
    
    %% compute cell areas
    cellAreas = zeros(l_max,1);
    for label=1:l_max
        cellAreas(label) = nnz(cellMembranes(label,:));
    end
    
    %% compute cell compactness (surface^3/volume^2)
    cellCompactness = cellAreas.^3 ./ cellVolumes.^2;
    
    %% compute cell membrane intensity statistics
    cellMembraneMeans  = zeros(l_max,1);
    cellMembraneStdDev = zeros(l_max,1);
    cellMembraneMedian = zeros(l_max,1);
    for label=1:l_max
        iSet = I(cellMembranes(label,1:length(cellAreas(label))));
        cellMembraneMeans(label) = mean(iSet);
        cellMembraneStdDev(label)= std(iSet);
        cellMembraneMedian(label)= median(iSet);
    end
    
    %% compute mean 3D solidity (volume/convex volume) and its stddev in terms of 2D solidities
    cellSolidity2d     = zeros(l_max,size(L,3)); cellSolidity3dMean = zeros(l_max,1);
    cellSolidity3dStd  = zeros(l_max,1);         cellFlattening     = zeros(l_max,1);
    minAxisLengths     = zeros(l_max,size(L,3)); majAxisLengths     = zeros(l_max,size(L,3));
    
    for s=1:size(L,3)
        slice = L(:,:,s);
        sliceStats = regionprops(slice,'Area','ConvexArea','MajorAxisLength','MinorAxisLength');
        for label=1:l_max
            cellSolidity2d(label,s) = sliceStats(label).Area/sliceStats(label).ConvexArea;
            minAxisLengths(label,s) = sliceStats(label).MinorAxisLength;
            majAxisLengths(label,s) = sliceStats(label).MajorAxisLength;
        end
    end
    %% compute minor/major axes ratio
    for label=1:l_max
        cellSolidity3dMean(label) = mean(cellSolidity2d(label,:));
        cellSolidity3dStd(label)  = std(cellSolidity2d(label,:));
        cellFlattening(label) = 1 - (mean(minAxisLengths(label,:))/mean(majAxisLengths(label,:)));
    end
    %% create adjacency matrix from label image
    fun = @(x) unique(x(:,:));
    A = zeros(l_max);
    L2 = L;
    [gx,gy,gz] = gradient(double(L2));
    L2((gx.^2+gy.^2+gz.^2)~=0) = 0;
    zeroIdx = find(L2==0);
    [Iadj,~,~] = neighbourND(zeroIdx,size(L2),[0.3,0.3,5]);
    for thisZero=1:length(Iadj)
        nonZeroIds = find(Iadj(thisZero,:)~=0);
        neighLabels = unique(L(Iadj(thisZero,nonZeroIds)));
        if length(neighLabels)>1
            for i=1:length(neighLabels)-1
                for j=i+1:length(neighLabels)
                    A(neighLabels(i),neighLabels(j))=1;
%                     A(neighLabels(j),neighLabels(i))=1;
                end
            end
        end
    end
    clearvars cellSolidity2d majAxisLengths majAxisLengths cellMembranes L2 nonZeroIds ...
        gx gy gz fun Iadj neighLabels slice sliceStats
    %% create a graph
    bg = biograph(A,[],'ShowWeights','on','ShowArrows','off');
    cellStats = zeros(l_max,9);
    for label=1:l_max
       nonZeroInd = find(A(label,:)==1);
       nonZeroInd = nonZeroInd(nonZeroInd>label);
       for i=1:length(nonZeroInd)
           edge  = getedgesbynodeid(bg,['Node ' int2str(label)],['Node ' int2str(nonZeroInd(i))]);
           cellStats(label,1) = cellVolumes(nonZeroInd(i))/cellVolumes(label);
           cellStats(label,2) = cellAreas(nonZeroInd(i))/cellAreas(label);
           cellStats(label,3) = cellCompactness(nonZeroInd(i))/cellCompactness(label);
           cellStats(label,4) = cellMembraneMeans(nonZeroInd(i))/cellMembraneMeans(label);
%            cellStats(label,5) = cellMembraneStdDev(nonZeroInd(i))/cellMembraneStdDev(label);
           cellStats(label,6) = cellMembraneMedian(nonZeroInd(i))/cellMembraneMedian(label);
           cellStats(label,7) = cellSolidity3dMean(nonZeroInd(i))/cellSolidity3dMean(label);
%            cellStats(label,8) = cellSolidity3dStd(nonZeroInd(i))/cellSolidity3dStd(label);
           cellStats(label,9) = cellFlattening(nonZeroInd(i))/cellFlattening(label);
           edge.Weight = mean(cellStats(label,:));
           if edge.Weight>0.6 && edge.Weight<1.4
               edge.LineColor = [0.0 0.7 0.1]; %green
           else
               edge.LineColor = [0.7 0.0 0.1]; %red
           end
           edge.LineWidth = 2.5;
       end
    end
%     set(bg,'Edges',cellVolumes)
    view(bg)
    
    
end











