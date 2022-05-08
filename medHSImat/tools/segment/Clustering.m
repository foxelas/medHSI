function submasks = Clustering(mask)

x1 = [];
x2 = [];
for i = 1:size(mask, 1)
    for j = 1:size(mask, 2)
        if mask(i, j) ~= 0
            x1 = [x1, i];
            x2 = [x2, j];
        end
    end
end
X = [x1; x2]';

% figure(1);
% scatter(X(:,1),X(:,2))
idx = dbscan(X, 5, 10);

% figure(2);
% gscatter(X(:,1),X(:,2),idx);
% title('DBSCAN Using Euclidean Distance Metric')

lbNum = unique(idx);
submasks = cell(max(lbNum), 1);
for k = 1:max(lbNum)
    kmask = zeros(size(mask));
    cols1 = X(idx == k, 1);
    cols2 = X(idx == k, 2);
    for i = 1:size(cols1)
        kmask(cols1(i), cols2(i)) = 1;
    end
    submasks{k} = kmask;
end

% figure(3);
% imshow(kmask);

end