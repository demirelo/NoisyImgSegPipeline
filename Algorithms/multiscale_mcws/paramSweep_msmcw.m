function paramSweep_msmcw(folder)
%PARAMETERSWEEP_MSMCW can be used to see which sigma and h combination
%works best for the datasets at hand. 
cd(folder);
allTiffs = dir('*.tif');
parfor i=1:numel(allTiffs)
    filename = allTiffs(i).name;
    for sigma=6:5:11
        for sigma2=0.9:-0.2:0.7
            for sigma3=0.9:-0.2:0.7
                s2 = sigma2*sigma;
                s3 = sigma3*sigma2;
                sigmaVec = [sigma s2 s3];
                for h=2:2:4
                    run_msmcws(filename,sigmaVec,h);
                end
            end
        end  
    end
    disp(['.... ' num2str(i) ' of ' num2str(numel(allTiffs))]);
end
end

