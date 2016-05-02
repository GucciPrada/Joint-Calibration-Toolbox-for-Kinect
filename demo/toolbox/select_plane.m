function [  ] = select_plane( ind, width, height, imd )

nan_value = 2047;

global depth_plane_mask
global depth_plane_poly
% get plane polygons for all images
[uu,vv] = meshgrid(0:width-1,0:height-1);
depth_plane_poly{ind} = select_plane_polygon(imd);
% extract mask
if(isempty(depth_plane_poly{ind}))
    depth_plane_poly{ind} = false(size(imd));
else
%     depth_plane_mask{ind} = inpolygon(uu,vv,depth_plane_poly{ind}(1,:),depth_plane_poly{ind}(2,:)) & ~isnan(imd);
    depth_plane_mask{ind} = inpolygon(uu,vv,depth_plane_poly{ind}(1,:),depth_plane_poly{ind}(2,:)) & ~(imd==nan_value);
end
fprintf('Select Plane Done\n');

end

