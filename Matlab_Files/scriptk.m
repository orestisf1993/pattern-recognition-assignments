clear all
close all
[c,IDXS1,IDXL1] =optimizer_kmeans(1,8);
initial_centroids={'random','random multiple iretations','heuristic'};
% cos = c(c(:,2)==1,:);
% cor = c(c(:,2)==2,:);


% plot_bars(cos,initial_centroids,'Using cosine as distance metric 8 clusters' ,'kmeansCosBar8',5);
% plot_bars(cor,initial_centroids,'Using correlation as distance metric 8 clusters' ,'kmeansCorBar8',5);


[c,IDXS2,IDXL2] =optimizer_kmeans(1,10);

cos = c(c(:,2)==1,:);
cor = c(c(:,2)==1,:);
% plot_bars(cos,initial_centroids,'Using cosine as distance metric 10 clusters' ,'kmeansCosBar10',4);
plot_bars(cor,initial_centroids,'Using correlation as distance metric 8 clusters' ,'kmeansCorBar10',4);

[c,IDXS3,IDXL3] =optimizer_kmeans(1,20);

cos = c(c(:,2)==1,:);
cor = c(c(:,2)==2,:);

plot_bars(cos,initial_centroids,'Using cosine as distance metric 20 clusters','kmeansCosBar20',4);
plot_bars(cor,initial_centroids,'Using correlation as distance metric 20 clusters','kmeansCorBar20',4);