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

function [z, out] = ClusteringCost(m, X)


    % Calculate Distance Matrix
    nclusts=8;

%       d = pdist2(X,'correlation');
      normM = sqrt(sum(m.^2, 2));
      D=zeros(80,8);
        for i = 1:nclusts
            D(:,i) = max(1 - X * (m(i,:)./normM(i))', 0);
        end
    
    % Assign Clusters and Find Closest Distances
    [dmin, ind] = min(D, [], 2);
    
%      dmin=abs(dmin);
    % Sum of Within-Cluster Distance
    WCD = sum(dmin);
    
    z=WCD;

    out.d=D;
    out.dmin=dmin;
    out.ind=ind;
    out.WCD=WCD;
    
    
end