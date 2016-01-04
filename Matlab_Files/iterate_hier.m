function [c ,lMethod ,distancesMap] = iterate_hier(X)

distancesMap = {'euclidean'; 'seuclidean'; 'cityblock'; 'minkowski';
  'chebychev';'cosine';'correlation';'spearman';'hamming';'jaccard'};
ls
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
        fprintf('Method %s  Distance %s c is %f \n',lMethod{i},distancesMap{j} ,c(k,1)); 
        
    end
end
% 