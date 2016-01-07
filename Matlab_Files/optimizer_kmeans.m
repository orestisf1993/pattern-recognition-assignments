function [c,IDXS,IDXL] = optimizer_kmeans( verb,clnumber)


paths_filename = '../2nd-assignment/datasets/paths.txt';
files = file_paths(paths_filename);

initial_centroids={'random','random multiple iretations','heuristic'};
distancesMap = {'cosine';'correlation'};
distancesMap2 = {'cosine   ','correlation'};

N = length(initial_centroids);
M = length(distancesMap);

F = length(files);
c  = zeros(M*N*(F-2),8);

number_of_iretation=10;
s_max = 0;
sil_max = 0;
k = 0;
for ff = 3:1:F
    T = readtable(files{ff});
    T(:,end) = [];%delete the category from the data
    X=table2array(T);
    heuristic_centroids=centroid_heuristic(X,80,clnumber);
    for i=1:M
        for j=1:N
            k = k +1;
            if j ==1
                IDX = kmeans(X,clnumber,'Distance',distancesMap(i));
                
            elseif j ==2
                IDX = kmeans(X,clnumber,'Distance',distancesMap(i),'Replicates',number_of_iretation);
                
            elseif j ==3
                IDX=     kmeans(X,clnumber,'Distance',distancesMap(i),'Start',heuristic_centroids);
            else
                error('Incoreect number of metrics')
            end
            
            [sil,coh,sep] = sil_coh_sep(X,IDX,distancesMap{i});
            succ1 = eval_clust(IDX,1);
            succ2 = eval_clust(IDX,2);
            c(k,:) = [ff,i,j,succ1,succ2,sil,coh,sep];
            strM = sprintf('Dataset :%d CentroidsMethod %s Dist:%s succ1:%3.3f succ2: %3.3f sil:%3.3f ,coh:%3.3f ,sep:%3.3f \n',...
                ff,initial_centroids{j},distancesMap2{i} ,succ1,succ2,sil,coh,sep);
            if verb ==1
                fprintf(strM)
            end
            
            if succ2 > s_max
                strMax = strM;
                s_max = succ2;
                IDXS = IDX;
            end
            if sil>sil_max
                sil_max = sil;
                strSil =strM;
                IDXL = IDX;
            end
            
        end
        
    end
    
    
end
fprintf('The best of ALL result was .. \n')
fprintf(strMax)
fprintf(strSil);
end

