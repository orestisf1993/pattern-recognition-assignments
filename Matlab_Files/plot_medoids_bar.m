function plot_medoids_bar(all_res, tit, name)
% set(0, 'currentfigure', h); % set current figure
% hold on; <<--- for some reasons breaks the colors for me.
% axes = h.CurrentAxes;

figure('visible', 'off', 'PaperType', 'a4', 'PaperOrientation', 'portrait', ...
  'PaperUnits', 'centimeters', 'PaperPosition', [0 0 21 29.7], 'PaperPositionMode', 'manual', ...
  'Menubar', 'none', 'defaulttextinterpreter', 'latex', 'units', 'normalized', 'outerposition', [0 0 1 1]);

y = [all_res{:, 5} all_res{:, 6} all_res{:, 7} all_res{:, 4}];
barh(y)

files = all_res{:, 1};
files = strrep(files(:), '../2nd-assignment/datasets/root/', '');
files = strrep(files(:), '_', '\_');

legend('Silhouette', 'Cohesion', 'Separation', 'Success\_Rate')

L = length(files);
x = cell(1, L);
for t = 1:1:L
    x{t} = strjoin([files{t}, '-', all_res{:, 3}(t)]);
end

title(tit)

set(gca, 'YTick', 1:L, 'YTickLabel', x)
set(gca, 'FontSize', 3)
ax = gca;
ax.Title.FontSize = 10;

set(ax, 'xlim', [0 1])
set(ax, 'XLimMode', 'manual')

% set colors for bars
cat = ax.Children;
set(cat(1), 'FaceColor', [230, 97, 1] / 255, 'EdgeColor', [230, 97, 1] / 255);
set(cat(2), 'FaceColor', [253, 184, 99] / 255, 'EdgeColor', [253, 184, 99] / 255);
set(cat(3), 'FaceColor', [178, 171, 210] / 255, 'EdgeColor', [178, 171, 210] / 255);
set(cat(4), 'FaceColor', [94, 60, 153] / 255, 'EdgeColor', [94, 60, 153] / 255);

print(name, '-dpdf', '-r0')
end
