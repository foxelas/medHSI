function joint = MeasureDensity(mask, gt)

if sum(mask(:)) > 0
    submasks = Clustering(mask);

    d = 0;
    for i = 1:numel(submasks)
        d = d + Density(submasks{i});
    end
    if numel(submasks) ~= 0
        d = d / numel(submasks);
    else
        d = 0;
    end

    jc = jaccard(mask, gt);
    joint = 0.8 * jc + 0.2 * d;
else
    joint = 0;
end
%     fprintf('Jaccard Coeff %.4f\nDensity %.4f\nJoint %.4f\n', jc, d, joint);
end

function d = Density(mask)

[m, n] = find(mask);
m1 = min(m);
m2 = max(m);
n1 = min(n);
n2 = max(n);

areaMask = sum(mask(m1:m2, n1:n2), "all");
areaTotal = (m2 - m1 + 1) * (n2 - n1 + 1);

d = areaMask / areaTotal;

end