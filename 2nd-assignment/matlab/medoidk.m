clear all
num_clust = 10;
filename = 'datasets1/datasetF8_50.csv';
T = readtable(filename);
T(:, end) = [];
X = table2array(T);

% normalize X
for x = 1:1:size(X, 1)
    X(x, :) = X(x, :) ./ max(X(x, :));
 
end

% starting_centroids=centroid_heuristic(X,number_of_features,total_centroid_counter);

[IDX, C, sse] = kmedoids(X, num_clust, 'Distance', 'correlation');

eval1 = eval_clust(IDX, 1)
eval2 = eval_clust(IDX, 2)

plot(IDX)
pause
close all
