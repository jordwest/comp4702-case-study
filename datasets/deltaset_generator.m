Y1 = -1:0.01:1;
Y1r = Y1+(randn(1,201)*0.05);

Y2 = -0.5:0.01:0.5;
Y2r = Y2+(randn(1,101)*0.05);

A = (-Y1r.^2)+1;
Ar = A+(randn(1,201)*0.03);

B = 2*(-Y2r.^2)+0.45;
Br = B+(randn(1,101)*0.03);

% Combined dataset
X = [Ar Br];
Y = [Y1r Y2r];

D = [X.' Y.'];

% Randomly sort the dataset
D = D(randperm(size(D,1)),:);

% Clear out values out of range (due to the randomness)
D = D(D(:, 1) > 0, :);
D = D(abs(D(:, 2)) < 1, :);

hold off;
plot(D(:,1), D(:,2), 'o');

Dataset = dataset(D);

export(Dataset, 'file', 'delta.data','delimiter', ',');