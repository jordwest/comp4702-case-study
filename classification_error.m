% COMP4702 Case Study
% Semester 1, 2012
%    Jordan West

% A Novel Kernel Method for Clustering
% Francesco Camastra, Member, IEEE, and
%       Alessandro Verri

% Utility for calculating classification error

% Calculates classification error given a list of named classes (original data)
% and a list of numbered classes (classification algo output)

function instances = classification_error(classnames, clusternumbers)
% Returns a matrix which indicates how two different naming schemes for
% clusters could be interpreted as correct/incorrect instances. Can be used
% for calculating classification error in clusters

    [dimRows, dimCols] = size(classnames);
    
    % NOTE: The behaviour of the 'unique' function may change in R2012a?
    % This code was only tested in R2011b
    discoveredClasses = unique(classnames);
    
    discoveredClusters = unique(clusternumbers)
    
    classCount = size(discoveredClasses, 1);
    clusterCount = size(discoveredClusters, 1);
    
    instances = zeros(classCount, clusterCount);
    
    for class = 1:classCount
        for cluster = 1:clusterCount
            % Find number of instances where the specified class and
            % cluster are the same
            A = strcmp(discoveredClasses(class), classnames) == 1;
            B = clusternumbers == discoveredClusters(cluster);

            instances(class, cluster) = sum(A == B == 1);
        end
    end
end