function [max_succ, max_sil, IDX_max_succ, IDX_max_sil, filename_max_succ, filename_max_sil] = optimize_medoid()
distance_types = {'cosine'; 'correlation'};

num_clust = 8;

paths_filename = '../2nd-assignment/datasets/paths.txt';
paths = file_paths(paths_filename);
datasets = {};
file_idx_start = 3;

for file_idx = file_idx_start:1:length(paths)
    % read dataset
    filename = paths{file_idx};
    T = readtable(filename);
    T(:, end) = []; % delete the category from the data
    datasets{file_idx - file_idx_start + 1} = {table2array(T), filename};
end

combs = allcombs(datasets, distance_types);
datasets = cat(1, combs{:, 1});
filenames = datasets(:, 2);
datasets = datasets(:, 1);
distance_types = combs(:, 2);

kmedoids_func = @(x, dist) kmedoids(x, num_clust, 'Distance', dist);
[IDX, C, SSE] = cellfun(kmedoids_func, datasets, distance_types, 'UniformOutput', false);

f = @(X, IDX, dist) sil_coh_sep(X, IDX, dist);
[sil, coh, sep] = cellfun(f, datasets, IDX, distance_types, 'UniformOutput', false);
% cat to arrays
sil = cat(1, sil{:});
coh = cat(1, coh{:});
sep = cat(1, sep{:});

eval_func = @(IDX) eval_clust(IDX, 2);
succ = cellfun(eval_func, IDX);
% max_succ, max_sil indeces
max_succ = find(max(succ) == succ);
max_sil = find(max(sil) == sil);
% IDX one besides another
IDX_max_succ = IDX(max_succ);
IDX_max_sil = IDX(max_sil);
% filenames one bellow another
filename_max_succ = filenames(max_succ);
filename_max_sil = filenames(max_sil);
end
