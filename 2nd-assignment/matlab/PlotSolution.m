%
% Copyright (c) 2015, Yarpiz (www.yarpiz.com)
% All rights reserved. Please read the "license.txt" for license terms.
%
% Project Code: YPML101
% Project Title: Evolutionary Clustering in MATLAB
% Publisher: Yarpiz (www.yarpiz.com)
% 
% Developer: S. Mostapha Kalami Heris (Member of Yarpiz Team)
% 
% Contact Info: sm.kalami@gmail.com, info@yarpiz.com
%

function PlotSolution(X, sol)

    % Cluster Centers
    m = sol.Position;
    k = size(m,1);
    
    % Cluster Indices
    ind = sol.Out.ind;
    
    Colors = hsv(k);
    
    for j=1:k
        Xj = X(ind==j,:);
        plot(Xj(:,1),Xj(:,2),'x','LineWidth',1,'Color',Colors(j,:));
        hold on;
    end
    
    plot(m(:,1),m(:,2),'ok','LineWidth',2,'MarkerSize',12);
    
    hold off;
    grid on;
    
end