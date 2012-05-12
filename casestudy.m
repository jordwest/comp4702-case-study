% COMP4702 Case Study
% Semester 1, 2012
%    Jordan West

% A Novel Kernel Method for Clustering
% Francesco Camastra, Member, IEEE, and
%       Alessandro Verri


%% Load datasets
wisconsin = dataset('File', 'datasets/breast-cancer-wisconsin.data', 'format', '%s%d%d%d%d%d%s%d%d%d%d', 'Delimiter', ',');

iris = dataset('File', 'datasets/iris.data', 'format', '%f%f%f%f%s', 'Delimiter', ',');
iris = set(iris, 'VarNames', {'A', 'B', 'C', 'D', 'Type'});

%% IRIS with K-Means
col1 = double(iris(:,3));
col2 = double(iris(:,2));
col3 = double(iris(:,1));
col4 = double(iris(:,4));

plot(col1, col2, 'x');

D = [col1 col2 col3 col4];

% Find cluster centres
C = kmeansj(D, 3);

%% Classify data points then compare to actual class
[dimRows, dimCols] = size(iris);
classes = zeros(dimRows,1);
for i=1:dimRows
    x_t = D(i,:);
    
    % Find the nearest cluster centre
    [Z, I] = min(pdist2(C, x_t));
    
    classes(i) = I;
end
iris_kmeans = horzcat(iris, dataset(classes, 'VarNames', {'Class'}))
%cov(horzcat(iris, dataset(classes)))

classification_error(iris_kmeans.Type, iris_kmeans.Class)