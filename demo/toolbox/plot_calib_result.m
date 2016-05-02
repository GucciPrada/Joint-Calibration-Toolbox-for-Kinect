function plot_calib_result( rgb_img, imd, calib_depth_img, ...
    add_noncalib_comparison, calib )

cropped_rgb_img = crop_image(rgb_img);

if add_noncalib_comparison % Compare with non-calibrated results
    
    set(gcf,'Position',[200 300 1500 800]);
    
    %% show non-calibrated results at first row
    non_calib_depth_img = 1 ./ (calib.dc(2)*double(imd) + calib.dc(1));

    % show color image
    subplot(2,3,1);
    imshow(rgb_img);
    title('color image','fontsize',18,'FontWeight','bold');
    
    % show depth image
    subplot(2,3,3);
    subimage(im2uint8(mat2gray(non_calib_depth_img)), jet); % imd depth_img
    axis off
    title('raw depth image','fontsize',18,'FontWeight','bold');

    % show superposition of depth map and rgb
    subplot(2,3,2);
    
    imshow(rgb_img);
    title('superposition','fontsize',18,'FontWeight','bold');
    hold on
    [m, n, ~] = size(rgb_img);
    if ~all(size(non_calib_depth_img)==[m n]);
        non_calib_depth_img = imresize(non_calib_depth_img, [m n]);
    end
    
    hss1 = imshow(im2uint8(mat2gray(non_calib_depth_img)));
    set(hss1, 'AlphaData', 0.5);
    hold off
    
    %% show calibrated results at second row
    % show color image
    subplot(2,3,4);
    imshow(cropped_rgb_img);
    title('cropped color image','fontsize',18,'FontWeight','bold');
    
    % show depth image
    subplot(2,3,6);
    subimage(im2uint8(mat2gray(calib_depth_img)),jet); % imd depth_img
    title(sprintf('calibrated depth image\nafter bilateral filter'),'fontsize',18,'FontWeight','bold');
    axis off
    
    % show superposition of depth map and rgb
    subplot(2,3,5);
    imshow(cropped_rgb_img);
    hold on
    hss2 = imshow(im2uint8(mat2gray(calib_depth_img)));
    set(hss2, 'AlphaData', 0.5);
    hold off
    title('superposition','fontsize',18,'FontWeight','bold');
    
else
    
    set(gcf,'Position',[200 300 1500 500]);
    
    %         imd = visualize_disparity(double(imd));
    
    %% Show calibrated results
    % show color image
    subplot(1,3,1);
    imshow(rgb_img);
    title('color image','fontsize',18,'FontWeight','bold');
    % show depth image
    subplot(1,3,3);
    subimage(im2uint8(mat2gray(calib_depth_img)), jet); % imd depth_img
    title('calibrated depth image','fontsize',18,'FontWeight','bold');
    axis off
    % show superposition of depth map and rgb
    subplot(1,3,2);
    imshow(rgb_img);
    title('superposition','fontsize',18,'FontWeight','bold');
    hold on
    hss1 = imshow(im2uint8(mat2gray(calib_depth_img)));
    set(hss1, 'AlphaData', 0.5);
    hold off
end


end

