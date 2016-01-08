close all
clear all
c =optimizer_hier(1);
lMethod = {'weighted'; 'ward'; 'complete'; 'average'};
cos = c(c(:,2)==1,:);
cor = c(c(:,2)==2,:); 
plot_bars(cos,lMethod,'Using cosine as distance metric' ,'hierCosBar',5);
plot_bars(cor,lMethod,'Using correlation as distance metric' ,'hierCorBar',5);

