function d =  MeasureDensity(mask ,gt)

    submasks = Clustering(mask); 

    d = 0;
    for i = 1:numel(submasks)
        d = d + Density(submasks{i});
    end
    if numel(submasks) ~=  0
        d = d / numel(submasks);
    else
        d = 0;
    end

    jc = jaccard(mask, gt);
    joint = 0.7 * jc + 0.3 * d; 
    fprintf('Jaccard Coeff %.4f\nDensity %.4f\nJoint %.4f\n', jc, d, joint);
end

function d = Density(mask)

 [m1, n1] = find(mask, 1);
 [m2, n2] = find(mask, 1, "last");
 areaMask = sum(mask(m1:m2, n1:n2), "all");
 areaTotal = (m2-m1+1) * (n2-n1+1);

 d = areaMask / areaTotal;

end