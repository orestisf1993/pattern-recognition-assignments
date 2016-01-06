clear all
close all
paths_filename = '../2nd-assignment/datasets/paths.txt';
files = file_paths(paths_filename);
num_clust  = [ 8 10 12 14 16];

for ff = 3:1:length(files)
    T = readtable(files{ff});
    T(:,end) = [];%delete the category from the data
    X=table2array(T);
    IDX = hier(X,8);
%     optimizer_hiera(X,2,1);
end
