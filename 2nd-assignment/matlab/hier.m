% function [ IDX] = hier()

paths_filename = '../datasets/paths.txt';
files = file_paths(paths_filename);

T = readtable(files{4});
T(:, end) = []; % delete the category from the data
X = table2array(T);

distance = 'correlation';
Y = pdist (X, distance);
YY = squareform(Y);
Z = linkage(YY, 'average');

YY = 1 - YY;
figure;
% Create the heat map.
imagesc(YY);
% Set the tile
title('Hierarhical Clustering HeatMap')
colormap jet
% Add a colorbar to display the scale of the data.
colorbar
saveas(gcf, '../doc/images/heatHier', 'epsc')

IDX = cluster(Z, 'maxclust', 8);

figure
dendrogram(Z)
saveas(gcf, '../doc/images/dentroHier', 'epsc')

eval1 = eval_clust(IDX, 1)
eval2 = eval_clust(IDX, 2)
