function paramSweep_mcws(folder)
%PARAMETERSWEEP_MSMCW can be used to see which sigma and h combination
%works best for the datasets at hand. 
cd(folder);
allTiffs = dir('*.tif');
for i=1:numel(allTiffs)
    filename = allTiffs(i).name;
    parfor sigma=4:11
        for h=2:4
            run_mcws(filename,sigma,h);
        end
    end
    disp(['.... ' num2str(i) ' of ' num2str(numel(allTiffs))]);
end
end

