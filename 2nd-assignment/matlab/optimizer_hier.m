function [c, IDXHS, IDXHL] = optimizer_hier(verb)

distancesMap2 = {'cosine   ', 'correlation'};
lMethod2 = {'weighted'; 'ward    '; 'complete'; 'average '};

distancesMap = {'cosine', 'correlation'};
lMethod = {'weighted'; 'ward'; 'complete'; 'average'};

paths_filename = '../datasets/paths.txt';
files = file_paths(paths_filename);

M = length(lMethod);
N = length(distancesMap);
F = length(files);
c = zeros(M * N * (F - 2), 8);

k = 0;
s_max_all = 0;
sil_max = 0;
for ff = 3:1:F
    T = readtable(files{ff});
    T(:, end) = []; % delete the category from the data
    X = table2array(T);
 
    s_max = 0;
    for j = 1:1:N
        for i = 1:1:M
            k = k + 1;
            Y = pdist(X, distancesMap{j});
            YY = squareform(Y);
            Z = linkage(YY, lMethod{i});
            IDX = cluster(Z, 'maxclust', 8);
            [sil, coh, sep] = sil_coh_sep(X, IDX, distancesMap{j});
            succ1 = eval_clust(IDX, 1);
            succ2 = eval_clust(IDX, 2);
            c(k, :) = [ff, j, i, succ1, succ2, sil, coh, sep];
             strM = sprintf('Dataset :%d Method %s Dist:%s succ:%3.3f sil:%3.3f ,coh:%3.3f ,sep:%3.3f \n', ...
              ff, lMethod2{i}, distancesMap2{j}, succ2, sil, coh, sep);
            if verb == 1
                fprintf(strM)
            end
         
            if succ2 > s_max
                strMax = strM;
                s_max = succ2;
            end
         
            if sil > sil_max
                sil_max = sil;
                strSil = strM;
                IDXHL = IDX;
            end
        end
        if s_max > s_max_all
            strMaxAll = strMax;
            s_max_all = succ2;
            IDXHS = IDX;
        end
    end
    fprintf('The best result was .. \n')
    fprintf(strMax)
end
fprintf('The best of ALL result was .. \n')
fprintf(strMaxAll)
fprintf(strSil);
end
