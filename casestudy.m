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

deltaset = dataset('File', 'datasets/delta.data', 'format', '%f%f', 'Delimiter', ',');
deltaset = set(deltaset, 'VarNames', {'X','Y'});

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


%% SVM Plot Hyperplane (gaussian) and delta function

sigma = 0.4

deltaX = double(deltaset(:,1));
deltaY = double(deltaset(:,2));
deltaG = exp(-(abs(deltaX.^2 + deltaY.^2))/(sigma^2));

[XX, YY] = ndgrid(0:0.01:1, -1:0.01:1.1);
ZZ = exp(-((abs(XX.^2 + YY.^2))/(sigma^2)));

hold off;
plot3(deltaX, deltaY, deltaG, 'r+');
hold on;
surf(XX, YY, ZZ, 'FaceColor', 'blue', 'EdgeColor', 'none', 'FaceAlpha', 0.2);
%alpha('clear');
camlight left; lighting phong;

[dimRows, dimCols] = size(deltaX);
lbls = [1:1:dimRows].';

% Number of clusters
K = 2;

fullset = [lbls deltaX deltaY zeros(dimRows,1)];

% Pick two random points
%init_points = (floor(rand(2,1)*dimRows));
init_points = [1; 106];

voronoi_points = zeros(K,3);
for i = 1:K
    voronoi_points(i,:) = [deltaX(init_points(i)) deltaY(init_points(i)) deltaG(init_points(i))];
end

MaxR = 0.4;

    
    for t = 1:length(deltaX)
        % find nearest voronoi points for each point in dataset
        x_t = [fullset(t, 2) fullset(t, 3) deltaG(t)];
        [C, I] = min(pdist2(voronoi_points, x_t));
%         if(C < MaxR)
%             fullset(t, 4) = I;
%         end
        % Classify correctly initially:
        if(deltaG(t) > 0.05)
            fullset(t, 4) = 1;
        else
            fullset(t, 4) = 2;
        end
        
        
    end

clusterColors = rand(K, 3);
   
for iteration = 1:6

    
    hold off;
    figure(iteration);
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
        % Grab just the data points that belong to this K
        V_current = fullset(fullset(:,4) == i,:);

        SVM = svmtrain(V_current(:,1), V_current(:,2:3), '-s 2 -t 2 -g 10 -n 0.01');
        TEST = svmpredict(fullset(:,1), fullset(:,2:3), SVM);
        
        Colors = clusterColors(i,:);
        
        % train on the surface
        for col = 1:surfCols
            CLIST = svmpredict(XX(:,col), [XX(:,col) YY(:,col)], SVM);
            for row = 1:surfRows
                if(CLIST(row) == 1)
                    surfColors(row,col,:) = Colors;
                end
            end
            
        end
        
        %SVM = svmtrain(V_current(:,1), [V_current(:,2) V_current(:,3)], '-s 2 -t 2 -g 0.4 -n 0.001');
        %TEST = svmpredict(fullset(:,1), [fullset(:,2) fullset(:,3)], SVM);

        % Classified
        new_V = fullset(TEST == 1,:);

        for p = 1:size(new_V,1)
            if(fullset(p,4) > 0)
                plot3(new_V(p,2), new_V(p,3), deltaG(new_V(p,1)), 'o', 'Color', Colors);
            end
        end
        
        sphereCtr = mean(SVM.SVs);
        sphereCtr = [mean(SVM.SVs) exp(-((abs(sphereCtr(1,1)^2 + sphereCtr(1,2)^2))/(sigma^2)))];
        voronoi_points(i,:) = [sphereCtr(1,1) sphereCtr(1,2) sphereCtr(1,3)];
        [SX, SY, SZ] = sphere;
        rad = pdist2(SVM.SVs(1,:), sphereCtr(:,1:2));
        pos = sphereCtr;
        SX = SX*rad + pos(1,1);
        SY = SY*rad + pos(1,2);
        SZ = SZ*rad + pos(1,3);
        %surf(SX, SY, SZ, 'FaceColor', Colors, 'EdgeColor', 'none', 'FaceAlpha', 0.4);

        % === ALGORITHM STEP 3 ===
        % Update new values into the voronoi set for the next iteration
        for z = 1:size(new_V,1)
            newset(newset(:,1) == new_V(z,1), 4) = i;
        end
    end
    
    surf(XX, YY, ZZ, surfColors, 'EdgeColor', 'none', 'FaceAlpha', 0.5);
    %plot3(XX,YY,ZZ, '+', 'Color', surfColors);
    %alpha('clear');
    camlight left; lighting phong;
    
    pause(1);

    fullset = newset;
end