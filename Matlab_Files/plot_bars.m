function plot_bars(c,tit,name)
% set(0, 'currentfigure', h); % set current figure
% hold on; <<--- for some reasons breaks the colors for me.
% axes = h.CurrentAxes;

dMap = {'COS'; 'COR'};
lMet = {'WE'; 'WA'; 'SI'; 'CO'; 'AV'};

% set(gca, 'XTick',1:10, 'XTickLabel',{l{1} l{2} 'C' 'D' 'E'})
% c(k,:) = [DATASET,DIST,MERTHOD,EVAL1,EVAL2,sil,coh,sep];

L = size(c,1);
figure('visible', 'off', 'PaperType', 'a4', 'PaperOrientation', 'portrait', ...
  'PaperUnits', 'centimeters', 'PaperPosition', [0 0 21 29.7], 'PaperPositionMode', 'manual', ...
  'Menubar', 'none', 'defaulttextinterpreter', 'latex', 'units', 'normalized', 'outerposition', [0 0 1 1]);
y = [c(:,6),c(:,7),c(:,8),c(:,5)];
barh(y)

paths_filename = '../2nd-assignment/datasets/paths.txt';
files = file_paths(paths_filename);

legend('Silhouette','Cohesion','Separation','Success\_Rate')
x = cell(1,L);
for t = 1:1:L
    x{t} = [files{(c(t, 1))} ,dMap{c(t, 2)}, lMet{c(t, 3)}];
end
% axis([ 0 inf 0 1 ]);


% set(gca, 'YTick', 1:L, 'YTickLabel', x)
% set(gca, 'YTickLabelRotation', 90)



% set(gca,'XTickLabelRotation',90)


title(tit)


set(gca, 'YTick',1:L, 'YTickLabel',x)
set(gca, 'FontSize', 3)
print(name, '-dpdf', '-r0')



close all

end
