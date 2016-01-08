function [centroid] = centroid_heuristic(X, number_of_features, total_centroid_counter)
% %Heuristic method for finding initial centroids.

% %First step:From n objects calculate a point whose attribute values are average of n-objects
% % attribute values.so first initial centroid is average on n-objects.

% %Second step:Select next initial centroids from n-objects in such a way that the Euclidean distance
% %of that object is maximum from other selected initial centroids.

% %Third step:repeat step 2 until we get k initial centroids.
% % From these steps we will get initial centroids and with these initial centroids perform kMeans
% % algorithm.

% 1st step :Find the average
initial_centroid = mean(X);
index = 1;
minimum_distance = norm(X(1, :) - initial_centroid);

for i = 2:1:number_of_features
    if norm(X(i, :) - initial_centroid) < minimum_distance
        minimum_distance = norm(X(i, :) - initial_centroid);
        index = i;
    end
end

centroid(1, :) = X(index, :);
centroid_counter = 1;

% 2nd step :Find the biggest distance

for i = 2:1:total_centroid_counter
    max_centroid_distance = 0;
    for k = 1:1:number_of_features
     
        new_centroid_distance = 0;
        for j = 1:1:centroid_counter
            new_centroid_distance = new_centroid_distance + norm(X(k, :) - centroid(j, :));
        end
     
        if new_centroid_distance > max_centroid_distance
            new_index = k;
            centroid(i, :) = X(new_index, :);
        end
    end
    centroid_counter = centroid_counter + 1;
end

end
