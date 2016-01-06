function [c ,lMethod ,distancesMap] = optimizer_hier(X,type)

% distancesMap = {'euclidean'; 'seuclidean'; 'cityblock'; 'minkowski';
%   'chebychev';'cosine';'correlation';'spearman';'hamming';'jaccard'};

distancesMap = {'cityblock'; 'minkowski';  'chebychev';'cosine';'correlation';
    'spearman';'hamming';'jaccard'};

lMethod = {'weighted';'ward';'single';  'complete' ;  'average'};
M = length(lMethod);
N = length(distancesMap);
c  = zeros(M*N,3);
k =0 ;
for i=1:1:M
    for j = 1:1:N
        k = k+1;
        Y = pdist(X,distancesMap{j});
        YY = squareform(Y);
        Z =linkage(YY,lMethod{i});
        c(k,:) = [cophenet(Z,Y),i,j];
        T = cluster(Z,'maxclust',8);
        s = eval_clust(T,type);
        fprintf('Method %s  Distance %s c is %f succes is %f \n',lMethod{i},distancesMap{j} ,c(k,1),s); 
        
    end
end
% 