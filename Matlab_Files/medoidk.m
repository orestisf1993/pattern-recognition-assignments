clear all
num_clust = 8;
filename = 'datasets/datasetF8_50.csv';
T = readtable(filename);
T(:,end) = [];
X=table2array(T);


%%nomralize X
for x =1:1:size(X,1)
    X(x,:) = X(x,:)./max(X(x,:));
    
end


% starting_centroids=centroid_heuristic(X,number_of_features,total_centroid_counter);

[IDX,C,sse] = kmeans(X,num_clust,'Distance','correlation');


eval1 = eval_clust(IDX,1)
eval2 = eval_clust(IDX,2)