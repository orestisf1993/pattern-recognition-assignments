function [sil,coh,sep] = sil_coh_sep( X,IDX,distance)
[sil] = sum(silhouette(X,IDX,distance))/length(IDX);
[coh,sep] = coh_sep(X,IDX,distance);
coh = sum(coh)/length(IDX);
sep(sep ==Inf) = 0;
sep = sum(sum(sep))/length(IDX)^2;
end

