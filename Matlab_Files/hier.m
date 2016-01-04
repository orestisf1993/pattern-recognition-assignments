
filename = 'datasets/datasetF8_50.csv';
T = readtable(filename);
T(:,end) = [];
X=table2array(T);

%%nomralize X
for x =1:1:size(X,1)
    X(x,:) = X(x,:)./max(X(x,:));
end


distance = 'correlation';
Y = pdist (X,distance);
YY = squareform(Y);
Z =linkage(YY,'single');
c = cophenet(Z,Y)

YY = 1-YY;
figure;
% Create the heat map.
imagesc(YY);
% Set the tile
title('Feature Heatmap')
colormap jet
% Add a colorbar to display the scale of the data.
colorbar
% T = cluster(Z,'cutoff',0.8);
T = cluster(Z,'maxclust',8);
figure
subplot(3,1,1)
plot(T)
subplot(3,1,2)
hist(T)
subplot(3,1,3)
dendrogram(Z)
