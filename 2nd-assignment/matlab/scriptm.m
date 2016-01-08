
[max_succ, max_sil, IDX_max_succ, IDX_max_sil, filename_max_succ, filename_max_sil, all_res] =optimize_medoids();
% plot_medoids_bar(all_res, 'Using cosine as distance metric','MedCosBar' )
plot_medoids_bar(all_res, 'Using correlation as distance metric','MedCorBar' )