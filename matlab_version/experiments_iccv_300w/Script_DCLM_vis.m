function Script_DCLM_vis()

addpath('../PDM_helpers/');
addpath('../fitting/normxcorr2_mex_ALL');
addpath('../fitting/');
addpath('../CCNF/');
addpath('../models/');

% Replace this with the location of in 300 faces in the wild data
if(exist([getenv('USERPROFILE') '/Dropbox/AAM/test data/'], 'file'))
    root_test_data = [getenv('USERPROFILE') '/Dropbox/AAM/test data/'];    
else
    root_test_data = 'D:/Dropbox/Dropbox/AAM/test data/';
end

[images, detections, labels] = Collect_wild_imgs(root_test_data);

images = images(:);
labels = labels(:,:,:);
    f = figure;
load('../experiments_in_the_wild/results/results_wild_dclm_general.mat');
output_root = './wild_fit_dclm/';
for i=1:numel(images)

    image = imread(images(i).img);
    image_orig = image;
    
    preds = experiments.shapes(:,:,i);

    actualShape = squeeze(labels(i,:,:));

    v_points = sum(squeeze(labels(i,:,:)),2) > 0;

    [height_img, width_img,~] = size(image_orig);
    width = max(actualShape(v_points,1)) - min(actualShape(v_points,1));
    height = max(actualShape(v_points,2)) - min(actualShape(v_points,2));
    sz = (width+height)/2.0;

    img_min_x = max(int32(min(actualShape(v_points,1))) - width/3,1);
    img_max_x = min(int32(max(actualShape(v_points,1))) + width/3,width_img);

    img_min_y = max(int32(min(actualShape(v_points,2))) - height/3,1);
    img_max_y = min(int32(max(actualShape(v_points,2))) + height/3,height_img);

    preds(:,1) = preds(:,1) - double(img_min_x);
    preds(:,2) = preds(:,2) - double(img_min_y);

    image_orig = image_orig(img_min_y:img_max_y, img_min_x:img_max_x, :);    

    scale = 600/sz;
    image_orig = imresize(image_orig, scale);
    
    % valid points to draw (not to draw
    % occluded ones)

%         f = figure('visible','off');

    try
    if(max(image_orig(:)) > 1)
        imshow(double(image_orig)/255, 'Border', 'tight');
    else
        imshow(double(image_orig), 'Border', 'tight');
    end
    axis equal;
    hold on;
    plot(preds(:,1) * scale, preds(:,2) * scale,'.r','MarkerSize', int32(40));
    plot(preds(:,1) * scale, preds(:,2) * scale,'.g','MarkerSize',int32(20));
%    plot(preds(:,1), preds(:,2),'.w','MarkerSize',40);
   % plot(preds(:,1), preds(:,2),'.k','MarkerSize',30);
   print(f, '-r80', '-dpng', sprintf('%s/%s%d_dclm.png', output_root, 'fit', i));
%     print(f, '-dpng', sprintf('%s/%s%d.png', output_root, 'fit', i));
%                                         close(f);
    hold off;
%         drawnow expose
%     close(f);
    catch warn

    end

end