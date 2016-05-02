%do_save_calib()
% UI function. Saves calibration data to disk.
% Kinect calibration toolbox by DHC
function do_save_calib(path)

global dataset_path rfiles rsize dfiles
global rgb_grid_p rgb_grid_x
global depth_corner_p depth_corner_x
global depth_plane_poly depth_plane_mask
global calib0
global final_calib final_calib_error

%Filename
if(nargin < 1 || isempty(path))
  path = input('Calibration path or filename:','s');
end
[path_dir,path_name,~] = fileparts(path);
if(~exist(path_dir,'dir'))
  mkdir(path_dir);
end

filename = [path_dir filesep() path_name '.mat'];
backup = [path_dir filesep() 'old_' path_name '.mat'];

%Data
depth_calib = [];
depth_calib.dataset_path = dataset_path;
depth_calib.rfiles = rfiles;
depth_calib.rsize = rsize;
depth_calib.dfiles = dfiles;
depth_calib.rgb_grid_p = rgb_grid_p;
depth_calib.rgb_grid_x = rgb_grid_x;
depth_calib.depth_corner_p = depth_corner_p;
depth_calib.depth_corner_x = depth_corner_x;
depth_calib.depth_plane_poly = depth_plane_poly;
depth_calib.depth_plane_mask = depth_plane_mask;
depth_calib.calib0 = calib0;
depth_calib.final_calib = final_calib;
depth_calib.final_calib_error = final_calib_error;

if(exist(filename,'file'))
  fprintf('Results file already exists, renaming old file to %s.\n',backup);
  movefile(filename,backup);
end
save(filename,'-struct','depth_calib');
fprintf('Calibration parameters and results saved to %s\n',filename);
