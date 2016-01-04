function [ success_percentage ] = eval_clust( T,type)
% %%This function implements the evaluation of the clustering.
%
% if nargin<2
%     mode =2;
% end
number_of_features=80;
real_data=zeros(1,number_of_features);
real_data(1,1:24)= 1;
real_data(1,25:35)=2;
real_data(1,36:45)=3;
real_data(1,46:55)=4;
real_data(1,56:64)=5;
real_data(1,65:71)=6;
real_data(1,72:75)=7;
real_data(1,76:80)=8;


if type==1
    incorrects = 0;
    corrects =0;
    max_clust = length(unique(T));
    for c = 1:1:max_clust
        el = real_data(T==c);
        d_lib = mode(el);
        incorrects = sum(el~= d_lib)+incorrects;
        corrects = sum(el == d_lib) + corrects;
        
    end
    success_percentage = corrects/(incorrects+corrects);
    corrects
    incorrects
    
end

RT = [real_data',T];
if type==2 %Trying to give one lib to one cluster
    corrects =0;
    incorrects = 0;
    max_clust = length(unique(T));
    libs = 1:1:max_clust;
    while(~isempty(RT))
        for l = 1:1:length(libs) %most common cluster
            
            el1 = RT(RT(:,1)==libs(l),2);
            d_clust = mode(el1);
            
            %             pause
            
            el2 = RT(RT(:,2)==d_clust,1);
            d_lib = mode(el2);
            %             pause
            %If it is the dominant remove it and count the mistakes
            if libs(l) == d_lib
                rem = find(RT(:,1)==libs(l));% remove all the libs
                RT(min(rem):max(rem),:)=[];
                % remove all the clusters
                rem = RT(:,2)==d_clust;% remove all the d_clusts
                RT(rem,:)=[];
                
%                 libs(l) = 0;
                corrects = sum(el2 == d_lib) + corrects;
%                 incorrects = sum(el2~= d_lib)+incorrects +sum(rem);
                fprintf('Cluster %f goes to library %f \n',d_clust,d_lib)
            end
            
           
        end
%         libs(libs==0) =[];
%         libs
    end
    incorrects = numel(RT)+incorrects;
    success_percentage = corrects/80;
%     corrects
%     incorrects
end


% end
