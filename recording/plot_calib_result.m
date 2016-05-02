function [ hc1, hd1, hs1, hss1 ] = plot_calib_result( rgb_img, imd, calib_depth_img, ...
    add_noncalib_comparison, calib )



set(gcf,'Position',[200 300 1500 500]);

%         imd = visualize_disparity(double(imd));

% Show calibrated results
% show color image
subplot(1,3,1);
hc1 = imshow(rgb_img);
title('color image','fontsize',18,'FontWeight','bold');
% show depth image
subplot(1,3,3);
hd1 = imshow(mat2gray(calib_depth_img)); % imd depth_img
title('calibrated depth image','fontsize',18,'FontWeight','bold');
% show superposition of depth map and rgb
subplot(1,3,2);
hs1 = imshow(rgb_img);
title('superposition of depth and color','fontsize',18,'FontWeight','bold');
hold on;
hss1 = imshow(mat2gray(calib_depth_img));
set(1, 'AlphaData', 0.5);
hold off

hc = []; hd = []; hs = []; hss = [];

end

