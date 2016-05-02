function debug_load_globals( )


global dataset_path rfiles rsize dfiles
global rgb_grid_p rgb_grid_x
global depth_corner_p depth_corner_x
global depth_plane_poly depth_plane_mask
global calib0
global is_validation
global final_calib final_calib_error

%max_depth_sample_count: The maximum number of disparity samples used for
%   full calibration. Used to limit memory usage.
global max_depth_sample_count 
max_depth_sample_count = 60000; 

% 
% % load rgb corners
% save_path = [filepath 'rgb_corners.mat'];
% 
% if ~isempty(dir(save_path))
%     load(save_path);
%     rgb_grid_p = loc_rgb_grid_p;
%     rgb_grid_x = loc_rgb_grid_x;
%     clear loc_rgb_grid_p loc_rgb_grid_x
% end
% 
% % load depth mask
% save_path = '../mydata/depth_plane_mask.mat';
% if ~isempty(dir(save_path))
%     load(save_path);
%     depth_plane_poly = loc_depth_plane_poly;
%     depth_plane_mask = loc_depth_plane_mask;
%     clear loc_depth_plane_poly loc_depth_plane_mask
% end
% 

end

