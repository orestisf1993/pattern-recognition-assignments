function plot_bars(c, h)
set(0, 'currentfigure', h); % set current figure
% hold on; <<--- for some reasons breaks the colors for me.
% axes = h.CurrentAxes;

dMap = {'COS'; 'COR'};
lMet = {'WE'; 'WA'; 'SI'; 'CO'; 'AV'};

L = size(c, 1);

y = [c(:, 5), c(:, 6), c(:, 7), c(:, 4)];
barh(y)
legend('Silhouette', 'Cohesion', 'Separation', 'Success\_Rate')
x = cell(1, L);

for t = 1:1:L
    x{t} = [num2str(c(t, 1)) dMap{c(t, 2)}, lMet{c(t, 3)}];
end

set(gca, 'YTick', 1:L, 'YTickLabel', x)
% set(gca, 'YTickLabelRotation', 90)
set(gca, 'FontSize', 3)
end