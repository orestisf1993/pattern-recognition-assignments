function plot_bars(c, lMethod, tit, name, eval)
% set(0, 'currentfigure', h); % set current figure
% hold on; <<--- for some reasons breaks the colors for me.
% axes = h.CurrentAxes;

L = size(c, 1);
figure('visible', 'off', 'PaperType', 'a4', 'PaperOrientation', 'portrait', ...
  'PaperUnits', 'centimeters', 'PaperPosition', [0 0 21 29.7], 'PaperPositionMode', 'manual', ...
  'Menubar', 'none', 'defaulttextinterpreter', 'latex', 'units', 'normalized', 'outerposition', [0 0 1 1]);
y = [c(:, 6), c(:, 7), c(:, 8), c(:, eval)];
barh(y)

paths_filename = '../datasets/paths.txt';
files = file_paths(paths_filename);
files = strrep(files(:), '../datasets/root/', '');
files = strrep(files(:), '_', '\_');

legend('Silhouette', 'Cohesion', 'Separation', 'Success\_Rate')

P = findobj(gca, 'type', 'patch');
C = ['w', 'k', 'm', 'g']; % color list
for n = 1:length(P)
    set(P(n), 'facecolor', C(n));
end

x = cell(1, L);
for t = 1:1:L
    x{t} = [files{(c(t, 1))}, '-', lMethod{c(t, 3)}];
end

title(tit)

set(gca, 'YTick', 1:L, 'YTickLabel', x)
set(gca, 'FontSize', 3)
ax = gca;
ax.Title.FontSize = 10;

% set colors for bars
cat = ax.Children;
set(cat(1), 'FaceColor', [230, 97, 1] / 255, 'EdgeColor', [230, 97, 1] / 255);
set(cat(2), 'FaceColor', [253, 184, 99] / 255, 'EdgeColor', [253, 184, 99] / 255);
set(cat(3), 'FaceColor', [178, 171, 210] / 255, 'EdgeColor', [178, 171, 210] / 255);
set(cat(4), 'FaceColor', [94, 60, 153] / 255, 'EdgeColor', [94, 60, 153] / 255);

print(['../doc/images/', name], '-dpdf', '-r0')

close all
end
