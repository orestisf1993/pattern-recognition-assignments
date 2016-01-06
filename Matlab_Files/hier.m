function [ T] = hier(filename12,num_clust)
% filename = 'datasets1/datasetF8_50.csv';

T = readtable(filename12);
T(:,end) = [];%delete the category from the data
X=table2array(T);

%%nomralize X
for x =1:1:size(X,1)
    X(x,:) = X(x,:)./max(X(x,:));
end


distance = 'correlation';
Y = pdist (X,distance);
YY = squareform(Y);
Z =linkage(YY,'weighted');
% c = cophenet(Z,Y)

% YY = 1-YY;
% figure;
% % Create the heat map.
% imagesc(YY);
% % Set the tile
% title('Feature Heatmap')
% colormap jet
% % Add a colorbar to display the scale of the data.
% colorbar

% T = cluster(Z,'cutoff',0.8);
IDX = cluster(Z,'maxclust',num_clust);

% 
% figure
% subplot(3,1,1)
% plot(T)
% subplot(3,1,2)
% hist(T)
% subplot(3,1,3)
% dendrogram(Z)


eval1 = eval_clust(IDX,1)
eval2 = eval_clust(IDX ,2)