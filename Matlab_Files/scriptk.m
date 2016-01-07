clear all
close all
c =optimizer_kmeans(1,8);

cos = c(c(:,2)==1,:);
cor = c(c(:,2)==2,:);
initial_centroids={'random','random multiple iretations','heuristic'};

plot_bars(cos,initial_centroids,'Using cosine as distance metric 8 clusters' ,'kmeansCosBar8',5);
plot_bars(cor,initial_centroids,'Using correlation as distance metric 8 clusters' ,'kmeansCorBar8',5);


c =optimizer_kmeans(1,10);

cos = c(c(:,2)==1,:);

plot_bars(cos,initial_centroids,'Using cosine as distance metric 10 clusters' ,'kmeansCosBar10',4);

c =optimizer_kmeans(1,20);

cos = c(c(:,2)==1,:);
cor = c(c(:,2)==2,:);

plot_bars(cos,initial_centroids,'Using correlation as distance metric 20 clusters','kmeansCosBar20',4);