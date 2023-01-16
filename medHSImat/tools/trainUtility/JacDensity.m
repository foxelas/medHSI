% ======================================================================
%> @brief JacDensity measures JAC-Density of a prediction mask.
%>
%> @b Usage
%>
%> @code
%> joint = JacDensity(mask, gt);
%> @endcode
%>
%> @param prediction [numeric array] | The prediction labels
%> @param groundTruth [numeric array] | The ground truth labels
%>
%> @retval jacdensity [double] | The JAC-Density value
% ======================================================================
function jacdensity = JacDensity(prediction, groundTruth)

if sum(prediction(:)) > 0
    submasks = Clustering(prediction);

    density = 0;
    for i = 1:numel(submasks)
        density = density + Density(submasks{i});
    end
    if numel(submasks) ~= 0
        density = density / numel(submasks);
    else
        density = 0;
    end

    jc = jaccard(prediction, groundTruth);
    ratio = 0.7;
    jacdensity = ratio * jc + (1 - ratio) * density;
else
    jacdensity = 0;
end
%     fprintf('Jaccard Coeff %.4f\nDensity %.4f\nJoint %.4f\n', jc, d, joint);
end

% ======================================================================
%> @brief Clustering applies initial clustering to calculate the JAC-Density metric.
%>
%> @b Usage
%>
%> @code
%> submasks = Clustering(mask);
%> @endcode
%>
%> @param mask [numeric array] | The input labels
%>
%> @retval submasks [cell array] | The output labels split in submasks
% ======================================================================
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


% ======================================================================
%> @brief Density measures density of a prediction mask to calculate the JAC-Density metric.
%>
%> @b Usage
%>
%> @code
%> joint = Density(mask);
%> @endcode
%>
%> @param mask [numeric array] | The input labels
%>
%> @retval density [double] | The density value
% ======================================================================
function density = Density(mask)

[m, n] = find(mask);
m1 = min(m);
m2 = max(m);
n1 = min(n);
n2 = max(n);

areaMask = sum(mask(m1:m2, n1:n2), "all");
areaTotal = (m2 - m1 + 1) * (n2 - n1 + 1);

density = areaMask / areaTotal;

end