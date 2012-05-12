% Calculates classification error given a list of named classes (original data)
% and a list of numbered classes (classification algo output)

function [err, correct, incorrect] = classification_error(classnames, classnumbers)
    [dimRows, dimCols] = size(classnames);
    
    % NOTE: The behaviour of the 'unique' function may change in R2012a?
    % This code was only tested in R2011b
    discoveredClasses = unique(classnames)
    
    [classCount, x] = size(discoveredClasses);
    
    correct = 0;
    incorrect = 0;
    
    for class = 1:classCount
        % Create a list of datapoints for this class only
        A = classnames(strcmp(discoveredClasses(class), classnames) == 1, :)
        B = classnumbers(strcmp(discoveredClasses(class), classnames) == 1, :)
        
        % Find the most common classification for this class
        classno = mode(B)
        
        % Find the number of values that were correctly classified
        correct = correct + sum(B == classno)
        incorrect = incorrect + sum(B ~= classno)
    end
    
    % Assign the named classes a number instead
    
%     for row = 1:dimRows
%         for class = 1:classCount           
%             scm = strcmp(discoveredClasses(class,1), classnames(row,1));
%             if(scm == 1)
%                 numberedClasses(row,1) = class;
%             end
%         end
%         
%         numberedClasses(row,2) = classnumbers(row);
%     end
    
    err = correct / (correct+incorrect);
end