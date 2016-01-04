
filename = 'dataset8_50.csv';
T = readtable(filename);
X=table2array(T);
%%nomralize X
for x =1:1:size(X,1)
    X(x,:) = X(x,:)./max(X(x,:));
end

distance = 'correlation';
Y = pdist (X,distance);
YY = squareform(Y);
Z =linkage(YY);

c = cophenet(Z,Y)
display_heatmap(X,distance);
% T = cluster(Z,'cutoff',0.8);
T = cluster(Z,'cutoff',1);
figure
subplot(2,1,1)
plot(T)
subplot(2,1,2)
hist(T)

