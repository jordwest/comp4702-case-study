% PRAC 4
% K Means Clustering
% Jordan West

function m = kmeansj(dataset, k)
    
    % Find the dimensions of the dataset
    [dimRows, dimCols] = size(dataset);
    
    % Create cluster centres (at random)
    m = (rand(k, dimCols)*7);
    
    % Create some different colours for each cluster
    plotColours = abs(rand(k,3));
    
    % Remember previous values for calculating convergence
    prevM = zeros(k, dimCols);
    
    % While not converged
    while(sum(abs(prevM - m)) > 0.001)
        prevM = m;
        
        hold off;
        
        b = zeros(dimRows, k);
        for t = 1:dimRows
            x_t = dataset(t,:);
            for i = 1:k
                m_i = m(i,:);
                %x_t - m_i
                pdist2(x_t, m_i);
            end
            %pdist2(m, x_t)
            [C, I] = min(pdist2(m, x_t));
            b(t,I) = 1;
            
            % Plot the data point
            if(dimCols == 2)
                plot(x_t(1,1), x_t(1,2), '+', 'Color', plotColours(I,:));
            end
            if(dimCols == 3)
                plot3(x_t(1,1), x_t(1,2), x_t(1,3), '+', 'Color', plotColours(I,:));
            end
            hold on;
        end
        
        % Plot the cluster centres
        if(dimCols == 2)
            plot(m(:,1), m(:,2), 'bo');
        end
        if(dimCols == 3)
            plot(m(:,1), m(:,2), m(:,3), 'bo');
        end
        
        for i = 1:k
            newCtr = zeros(1, dimCols);
            for t = 1:dimRows
                x_t = dataset(t,:);
                newCtr = newCtr + b(t,i)*x_t;
            end
            newCtr = newCtr/sum(b(:,i));
            m(i,:) = newCtr;
        end
        
        % Pause between iterations for observing algorithm on plot
        pause(0.2);
    end

    m
end