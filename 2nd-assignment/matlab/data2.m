clear all;

distanceinput1 = 5;
while (distanceinput1 ~=1 && distanceinput1~=2)
prompt1='Press 1 for dataset3_70 else press 2 for dataset8_50 \n';
distanceinput1 = input(prompt1);
    if distanceinput1==1;
       filename ='dataset3_70.csv';

    elseif distanceinput1==2
       filename ='dataset8_50.csv';
    else
        fprintf('ERROR INPUT \n');
        prompt='Press 1 for correlation distance and 2 for cosine distance \n';
        distanceinput1 = input(prompt);
    end
end
T = readtable(filename);
T(:,end) = [];
X=table2array(T);