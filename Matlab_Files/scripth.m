clear all
close all
paths_filename = '../Matlab_Files/datasets2/paths.txt';
files = file_paths(paths_filename);
num_clust  = [ 8 10 12 14 16];

for ff = 3:1:length(files)
   hier(files{ff},8);
end
