function [] = portrait_print(filename, function_that_plots)
h = figure('visible', 'off', 'PaperType', 'a4', 'PaperOrientation', 'portrait', ...
  'PaperUnits', 'centimeters', 'PaperPosition', [0 0 21 29.7], 'PaperPositionMode', 'manual', ...
  'Menubar', 'none', 'defaulttextinterpreter', 'latex', 'units', 'normalized', 'outerposition', [0 0 1 1]);

function_that_plots(h);
print(filename, '-dpdf', '-r0')
end
