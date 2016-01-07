close all
clear all
c =optimizer_hier(1);
lMethod = {'weighted'; 'ward'; 'complete'; 'average'};
cos = c(c(:,2)==1,:);
cor = c(c(:,2)==2,:);

% 
plot_bars(cos,lMethod,'Using cosine as distance metric' ,'hierCosBar',5);
plot_bars(cor,lMethod,'Using correlation as distance metric' ,'hierCorBar',5);

% h = figure(1);
% f=@(h)plot_bars(c,h);
% portrait_print('bar.pdf', f)
% 

% lMethod = {'weighted';'ward';'single';'complete';'average'};
% we = c(c(:,3)==1,:);
% wa = c(c(:,3)==2,:);
% si =c(c(:,3)==3,:);
% comp = c(c(:,3)==4,:);
% average =c(c(:,3)==5,:);


% pause
% close all
