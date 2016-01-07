function plot_bars(c,tit,name)
% set(0, 'currentfigure', h); % set current figure
% hold on; <<--- for some reasons breaks the colors for me.
% axes = h.CurrentAxes;

dMap = {'COS'; 'COR'};
lMet = {'WE'; 'WA'; 'SI'; 'CO'; 'AV'};

% set(gca, 'XTick',1:10, 'XTickLabel',{l{1} l{2} 'C' 'D' 'E'})
% c(k,:) = [DATASET,DIST,MERTHOD,EVAL1,EVAL2,sil,coh,sep];

L = size(c,1);
figure('units','normalized','outerposition',[0 0 1 1])
set(gcf, 'PaperPositionMode', 'auto');
y = [c(:,6),c(:,7),c(:,8),c(:,5)];
bar(y)

legend('Silhouette','Cohesion','Separation','Success\_Rate')
x = cell(1,L);
for t = 1:1:L
    x{t} = [num2str(c(t, 1)) dMap{c(t, 2)}, lMet{c(t, 3)}];
end
% axis([ 0 inf 0 1 ]);


% set(gca, 'YTick', 1:L, 'YTickLabel', x)
% set(gca, 'YTickLabelRotation', 90)
% set(gca, 'FontSize', 3)


set(gca, 'XTick',1:L, 'XTickLabel',x)
set(gca,'XTickLabelRotation',90)


title(tit)
saveas(gcf,['../2nd-assignment/doc/images/',name],'epsc')

close all

end
