function  plot_bars(c)

dMap = {'COS';'COR'};
lMet = {'WE';'WA';'SI';'CO';'AV'};


% set(gca, 'XTick',1:10, 'XTickLabel',{l{1} l{2} 'C' 'D' 'E'})
% c(k,:) = [DATASET,DIST,MERTHOD,EVAL1,EVAL2,sil,coh,sep];
%  saveas(gcf,'Barchart','epsc')
%  saveas(gcf,'Barchart','png')
L = size(c,1);

y = [c(:,5),c(:,6),c(:,7),c(:,4)];
bar(y)
legend('Silhouette','Cohesion','Separation','Success\_Rate')
x = cell(1,L);

for t = 1:1:L
 x{t} = [num2str(c(t,1)) dMap{c(t,2)},lMet{c(t,3)}];
end

set(gca, 'XTick',1:L, 'XTickLabel',x)
set(gca,'XTickLabelRotation',90)
end