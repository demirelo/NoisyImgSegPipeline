function paramSweep_mcws(folder)
%PARAMETERSWEEP_MSMCW Summary of this function goes here
%   Detailed explanation goes here
cd(folder);
allTiffs = dir('*.tif');
for i=1:numel(allTiffs)
    filename = allTiffs(i).name;
    parfor sigma=4:1:11
        for h=2:4
            run_mcws(filename,sigma,h)
        end
    end
    disp(['.... ' num2str(i) ' of ' num2str(numel(allTiffs)) ' is done!']);
end
end

