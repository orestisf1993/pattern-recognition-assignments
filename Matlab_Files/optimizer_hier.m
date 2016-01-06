function [c ,lMethod ,distancesMap] = optimizer_hier(X,type,verb)

% distancesMap = {'euclidean'; 'seuclidean'; 'cityblock'; 'minkowski';
%   'chebychev';'cosine';'correlation';'spearman';'hamming';'jaccard'};

distancesMap2 = {'cosine     ';'correlation'};
lMethod2 = {'weighted';'ward    ';'single  ';'complete' ;  'average '};
distancesMap = {'cosine';'correlation'};
lMethod = {'weighted';'ward';'single';'complete';'average'};
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
        succ = eval_clust(IDX,type);
        strM = sprintf('Method %s Dist:%s c:%1.3f succ:%3.3f sil:%3.3f ,coh:%3.3f ,sep:%3.3f \n',...
            lMethod2{i},distancesMap2{j} ,c(k,1),succ,sil,coh,sep);
        if verb ==1
            fprintf(strM)
        end
        if sil > s_max
            strMax = strM;
            s_max = sil;
        end
        
    end
    
end


fprintf('The best result was .. \n')
fprintf(strMax)
end