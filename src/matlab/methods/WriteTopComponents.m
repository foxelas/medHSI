function [] = WriteTopComponents(redHsis, method)
% WriteTopComponents writes the top components of a reduced dimension
% sample as an image and as a .mat file
%
%   Usage:
%   WriteTopComponents(redHsis, method);

folder = 'test_tissue';
topNum = 3;

for i = 1:numel(sizeProd)
    redHsi = redHsis{i};
    sampleName = strcat('tissue', num2str(i));

    %% Prepare 3-top components
    dbDir = DirMake(GetSetting('saveDir'), 'database', folder, method);

    img = redHsi(:, :, 1:topNum);

    figure(9);
    imshow(img);
    imwrite(img, DirMake(dbDir, strcat(lower(sampleName), '.jpg')), 'jpg');

    save(DirMake(dbDir, strcat(lower(sampleName), '.mat')), 'img');
end

end