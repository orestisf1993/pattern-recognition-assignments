function [ success_percentage ] = eval_clust( T)
%%This function implements the evaluation of the clustering.

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

incorrects = 0;
corrects =0;
max_clust = length(unique(T));
for c = 1:1:max_clust
    el = real_data(T==c);
    d_class = mode(el);
    incorrects = sum(el~= d_class)+incorrects;
    corrects = sum(el == d_class) + corrects;
    
end
success_percentage = corrects/(incorrects+corrects);

end