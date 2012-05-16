% COMP4702 Case Study
% Semester 1, 2012
%    Jordan West

% A Novel Kernel Method for Clustering
% Francesco Camastra, Member, IEEE, and
%       Alessandro Verri

% Interpretation of method from above paper performed on the Delta Set

%% Load datasets

deltaset = dataset('File', 'datasets/delta.data', 'format', '%f%f', 'Delimiter', ',');
deltaset = set(deltaset, 'VarNames', {'X','Y'});

%% Set up algorithm

%
sigma = 0.4

% Number of clusters
K = 2;

deltaX = double(deltaset(:,1));
deltaY = double(deltaset(:,2));
deltaG = exp(-(abs(deltaX.^2 + deltaY.^2))/(sigma^2));

% Create a grid across the data range for plotting the kernel fn
[XX, YY] = ndgrid(0:0.01:1, -1:0.01:1.1);
ZZ = exp(-((abs(XX.^2 + YY.^2))/(sigma^2)));

hold off;
plot3(deltaX, deltaY, deltaG, 'r+');
hold on;
camlight left; lighting phong;

[dimRows, dimCols] = size(deltaX);
lbls = [1:1:dimRows].';


% First column is a label for each observation
% Fourth column is for storing the cluster id attributed to the observation
fullset = [lbls deltaX deltaY zeros(dimRows,1)];

% Pick two random points
init_points = (floor(rand(2,1)*dimRows));
%init_points = [1; 106];

voronoi_points = zeros(K,3);
for i = 1:K
    voronoi_points(i,:) = [deltaX(init_points(i)) deltaY(init_points(i)) deltaG(init_points(i))];
end

% Maximum euclidean distance from feature to voronoi point in feature space
MaxR = 0.4;

%% === ALGORITHM STEP 1 ===
% Initialize voronoi sets for clustering

for t = 1:length(deltaX)
    % find nearest voronoi points for each point in dataset
    x_t = [fullset(t, 2) fullset(t, 3) deltaG(t)];
    [C, I] = min(pdist2(voronoi_points, x_t));
    % Assign feature to nearest voronoi point cluster
    if(C < MaxR)
        fullset(t, 4) = I;
    end

    % For testing, use a known hyperplane to slice the data in feature
    % space. The below clusters the Delta Set with 100% accuracy when
    % using a guassian kernel with sigma = 0.4
%     if(deltaG(t) > 0.05)
%         fullset(t, 4) = 1;
%     else
%         fullset(t, 4) = 2;
%     end
end
clusterColors = rand(K, 3);

%% Iterate through steps 2 and 3
for iteration = 1:6

    hold off;
    figure(iteration);
    % Draw all the 
    plot3(deltaX, deltaY, deltaG, 'r+');
    camorbit(110, 30);
    hold on;
    
    [surfRows, surfCols] = size(XX);
    surfColors = zeros(surfRows, surfCols, 3);
    
    % Train for each K
    newset = fullset;
    % Assume all points are unclassified first
    newset(:,4) = zeros(size(fullset,1), 1);
    for i = 1:K
        % Grab just the data points that belong to this Voronoi set
        V_current = fullset(fullset(:,4) == i,:);

        % === ALGORITHM STEP 2 ===
        % Train one-class SVM
        SVM = svmtrain(V_current(:,1), V_current(:,2:3), '-s 2 -t 2 -g 10 -n 0.01');
        TEST = svmpredict(fullset(:,1), fullset(:,2:3), SVM);
        
        % Color of the current cluster
        Colors = clusterColors(i,:);
        % Train on the grid to get a visualisation of the cluster
        % regions
        for col = 1:surfCols
            CLIST = svmpredict(XX(:,col), [XX(:,col) YY(:,col)], SVM);
            for row = 1:surfRows
                if(CLIST(row) == 1)
                    surfColors(row,col,:) = Colors;
                end
            end
        end

        % Classified observations
        new_V = fullset(TEST == 1,:);

        for p = 1:size(new_V,1)
            if(fullset(p,4) > 0)
                plot3(new_V(p,2), new_V(p,3), deltaG(new_V(p,1)), 'o', 'Color', Colors);
            end
        end

        % === ALGORITHM STEP 3 ===
        % Update new values into the voronoi set for the next iteration
        for z = 1:size(new_V,1)
            newset(newset(:,1) == new_V(z,1), 4) = i;
        end
    end
    
    surf(XX, YY, ZZ, surfColors, 'EdgeColor', 'none', 'FaceAlpha', 0.5);
    camlight left; lighting phong;
    fullset = newset;
end