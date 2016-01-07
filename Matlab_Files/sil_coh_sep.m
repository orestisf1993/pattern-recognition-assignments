function [sil,coh,sep] = sil_coh_sep( X,IDX,distance)
[sil] = sum(silhouette(X,IDX,distance))/80;
[coh,sep] = coh_sep(X,IDX,distance);
coh = sum(coh)/2000;
sep(sep ==Inf) = 0;
sep = sum(sum(sep))/10000;
end

