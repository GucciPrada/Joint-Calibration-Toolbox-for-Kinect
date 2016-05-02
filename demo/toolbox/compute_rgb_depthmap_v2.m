function [ depthmap, depthmap_filled ]=compute_rgb_depthmap_v2( rgb_img, imd, calib, im_size )

if(nargin < 4)
  width = 640;
  height = 480;
else
  width = im_size(2);
  height = im_size(1);
end

x=disparity2world([],[], imd, calib);
p=project_points_k(x,calib.rK{1},calib.rkc{1});

p = round(p);
depthmap = nan(1, height*width);

% Optimation applied by Wei Xiang
p = bsxfun(@max, p, ones(size(p)));
p(1,:) = bsxfun(@min, p(1, :), ones(1, size(p, 2))*width);
p(2,:) = bsxfun(@min, p(2, :), ones(1, size(p, 2))*height);
depthmap(sub2ind([height width], p(2,:), p(1,:))) = x(3,:);
depthmap = reshape(depthmap, [height width]);
depthmap(isnan(depthmap)) = 0 ;

depthmap_filled = fill_depth_cross_bf(crop_image(rgb_img), double(crop_image(depthmap)));


end