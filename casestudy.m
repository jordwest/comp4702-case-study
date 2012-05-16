% COMP4702 Case Study
% Semester 1, 2012
%    Jordan West

% A Novel Kernel Method for Clustering
% Francesco Camastra, Member, IEEE, and
%       Alessandro Verri

% K-Means Clustering

%% Load datasets
%wisconsin = dataset('File', 'datasets/breast-cancer-wisconsin.data', 'format', '%s%d%d%d%d%d%s%d%d%d%d', 'Delimiter', ',');

iris = dataset('File', 'datasets/iris.data', 'format', '%f%f%f%f%s', 'Delimiter', ',');
iris = set(iris, 'VarNames', {'A', 'B', 'C', 'D', 'Type'});

wisconsin = dataset('File', 'datasets/breast-cancer-wisconsin.data', 'format', '%d%d%d%d%d%d%d%d%d%d%s', 'Delimiter', ',');
wisconsin = set(wisconsin, 'VarNames', {'ID', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'Type'});

spam = dataset('File', 'datasets/spambase.data', 'format', '%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%s', 'Delimiter', ',');
VNames = cell(1,58);
% Add labels to the attributes (unique values required so that the 'Type'
% name can be set)
for i = 1:57
    VNames(1,i) = strcat({'Attr'}, {int2str(i)});
end
VNames(1,58) = {'Type'};
spam = set(spam, 'VarNames', VNames);

%% K-Means Clustering

% == IRIS DATASET ==
%  attribs = iris(:,1:4);
%  data = iris(:,1:5);
%  K = 3;

% == WISCONSIN DATASET ==
 attribs = wisconsin(:,2:10);
 data = wisconsin(:,2:11);
 K = 2;

% == SPAMBASE DATASET ==
% attribs = spam(:,1:57);
% data = spam(:,1:58);
% K = 2;

% Perform principle component analysis on iris dataset to reduce the n
% dimensions down to 2 principle components
[COEFF, SCORE] = princomp(double(attribs));

plot(SCORE(:,1), SCORE(:,2), 'x');

%D = SCORE(:,1:4);         % 2-Dimensional K-means using 2 principle comps
D = double(attribs);       % N-Dimensional K-means

% Find cluster centres
C = kmeansj(D, K);

%% Classify data points then compare to actual class
[dimRows, dimCols] = size(data);
classes = zeros(dimRows,1);
for i=1:dimRows
    x_t = D(i,:);
    
    % Find the nearest cluster centre
    [Z, I] = min(pdist2(C, x_t));
    
    classes(i) = I;
end
d_kmeans = horzcat(data, dataset(classes, 'VarNames', {'Class'}))

classification_error(d_kmeans.Type, d_kmeans.Class)

