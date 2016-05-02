%do_save_calib()
% UI function. Saves calibration data to disk.
% Kinect calibration toolbox by DHC
function do_save_tmp_calib(path, rgb, imd, ind)

global dataset_path
global rgb_grid_p rgb_grid_x
global depth_plane_poly depth_plane_mask
global final_calib

%Filename
if(nargin < 1 || isempty(path))
  path = input('Calibration path or filename:','s');
end
[path_dir,path_name,~] = fileparts(path);
if(~exist(path_dir,'dir'))
  mkdir(path_dir);
end

filename = [path_dir filesep() 'tmp_calib' '.mat'];
if exist(filename, 'file') == 2
    load(filename);
else
    depth_calib = [];
end

%Data
rgb_fout_name = [gen_frame_number(ind) '-c1.jpg'];
imd_fout_name = [gen_frame_number(ind) '-d.pgm'];
depth_calib.rfiles{ind+1} = rgb_fout_name;
depth_calib.dfiles{ind+1} = imd_fout_name;
depth_calib.rsize{1} = size(rgb);
depth_calib.dataset_path = dataset_path;
depth_calib.rgb_grid_p = rgb_grid_p;
depth_calib.rgb_grid_x = rgb_grid_x;
depth_calib.depth_plane_poly = depth_plane_poly;
depth_calib.depth_plane_mask = depth_plane_mask;


save(filename,'depth_calib');
fprintf('Temporary calibration corner detection results saved to %s\n', filename);

% save images
imwrite(rgb, [path rgb_fout_name], 'jpg');
% remap disparity data
dis_img = remap_disparity(uint16(imd), 2047); % scale disparity data for display
imwrite(dis_img, [path imd_fout_name], 'pgm', 'MaxValue', 2047);

final_calib = depth_calib;
