% function [ IDX] = hier()

paths_filename = '../2nd-assignment/datasets/paths.txt';
files = file_paths(paths_filename);

T = readtable(files{4});
T(:,end) = [];%delete the category from the data
X=table2array(T);

distance = 'correlation';
Y = pdist (X,distance);
YY = squareform(Y);
Z =linkage(YY,'average');
% c = cophenet(Z,Y)

YY = 1-YY;
figure;
% Create the heat map.
imagesc(YY);
% Set the tile
title('Hierarhical Clustering HeatMap')
colormap jet
% Add a colorbar to display the scale of the data.
colorbar
saveas(gcf,'../2nd-assignment/doc/images/heatHier','epsc')

% T = cluster(Z,'cutoff',0.8);
IDX = cluster(Z,'maxclust',8);

%
% figure
% subplot(3,1,1)
% plot(T)
% subplot(3,1,2)
% hist(T)
figure
dendrogram(Z)
saveas(gcf,'../2nd-assignment/doc/images/dentroHier','epsc')


eval1 = eval_clust(IDX,1)
eval2 = eval_clust(IDX ,2)