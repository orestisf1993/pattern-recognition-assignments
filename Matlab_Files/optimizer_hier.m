function [c ,lMethod ,distancesMap] = optimizer_hier(X,type,verb)

% distancesMap = {'euclidean'; 'seuclidean'; 'cityblock'; 'minkowski';
%   'chebychev';'cosine';'correlation';'spearman';'hamming';'jaccard'};

distancesMap = {'cosine';'correlation'};

lMethod = {'weighted';'ward';'single';  'complete' ;  'average'};
M = length(lMethod);
N = length(distancesMap);
c  = zeros(M*N,3);
k =0 ;
s_max = 0;
for i=1:1:M
    for j = 1:1:N
        k = k+1;
        Y = pdist(X,distancesMap{j});
        YY = squareform(Y);
        Z =linkage(YY,lMethod{i});
        c(k,:) = [cophenet(Z,Y),i,j];
        IDX = cluster(Z,'maxclust',8);
        [sil,coh,sep] = sil_coh_sep(X,IDX,distancesMap{j});
        strM = sprintf('Method %s  Distance %s c is %f succes is %f \n',lMethod{i},distancesMap{j} ,c(k,1),s);
        if verb ==1
            fprintf(strM)
        end
        if s > s_max
            strMax = strM;
            s_max = s;
        end
        
    end
    
end


fprintf('The best result was .. \n')
fprintf(strMax)
end