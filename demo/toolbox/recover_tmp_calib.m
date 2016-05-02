function recover_tmp_calib(data_path)

% Run this script only when you have labeled part/all of the dataset 

if nargin < 2
    data_path = '../A5/';
end

% get_wall_images('../wall/', data_path, 45); 

calib_tmp_file = [data_path 'tmp_calib.mat'];

%% Load temporary data
load(calib_tmp_file);

new_calib = depth_calib;
loc_rfiles = new_calib.rfiles;
loc_dfiles = new_calib.dfiles;
loc_rsize = new_calib.rsize;
loc_rgb_grid_p = new_calib.rgb_grid_p;
loc_rgb_grid_x = new_calib.rgb_grid_x;
loc_depth_plane_poly = new_calib.depth_plane_poly;
loc_depth_plane_mask = new_calib.depth_plane_mask;

%% Processing
% %******************************************************************
% When you finish capturing all dataset, the wall images will be copied to
% directory of that dataset, in case that you need to capture wall images
% for all datasets (unless for some reason that you want to).
% Therefore, this script will detect wall images and help create filenams
% and masks for their disparity images automatically.
% %******************************************************************
dfiles = depth_calib.dfiles;
% dfiles = loc_dfiles;

file_names = getAllFiles(data_path);
rgb_cnt = 1; imd_cnt = 1;
for i = 1 : length(file_names)
    [~, names{i}, ext{i}] = fileparts(file_names{i});
    if ext{i} == '.pgm'
        imd_ind(imd_cnt) = sscanf(names{i}, '%d-d');
        imd_cnt = imd_cnt + 1;
    elseif ext{i} == '.jpg'
        rgb_ind(rgb_cnt) = sscanf(names{i}, '%d-c1');
        rgb_cnt = rgb_cnt + 1;
    else
        continue;
    end
   
end

rgb_file_mask = zeros(length(file_names), 1);
imd_file_mask = zeros(length(file_names), 1);

rgb_file_mask(rgb_ind+1) = 1; % plus 1 to fit indece that starts from 0
imd_file_mask(imd_ind+1) = 1;

% find indice of disparity images which has no cossponding color image,
% i.e. wall images
ind = imd_file_mask & ~(rgb_file_mask & imd_file_mask);
ind = find(ind) - 1; % minus one to recover to real indice

imd_width = 640;
imd_height = 480;

% append dfiles, depth_plane_poly, depth_plane_mask cells for wall images
n_dfiles = length(dfiles);
cnt = 1;
for i = 1 : length(ind)
    % generate file names for all wall images
    loc_dfiles{n_dfiles+cnt} = [gen_frame_number(ind(i)) '-d.pgm'];
    loc_rfiles{1}{n_dfiles+cnt} = [];
    loc_rgb_grid_p{1}{n_dfiles+cnt} = [];
    loc_rgb_grid_x{1}{n_dfiles+cnt} = [];
    imd = read_disparity([data_path loc_dfiles{n_dfiles+cnt}]);
    
    % generate mask for all wall images
    % -- considering null band generated in disparity image (8 pixels)
    loc_depth_plane_poly{n_dfiles+cnt} = [1 1 (imd_width-8) (imd_width-8);
                                        1 imd_height imd_height 1] - 1; % minus 1 to be in accordence with meshgrid coordinates
                                    
    [uu,vv] = meshgrid(0:imd_width-1,0:imd_height-1);
    % extract mask
    loc_depth_plane_mask{n_dfiles+cnt} = inpolygon(uu,vv,loc_depth_plane_poly{n_dfiles+cnt}(1,:),loc_depth_plane_poly{n_dfiles+cnt}(2,:)) & ~isnan(imd);
    
    cnt = cnt + 1;
end

% for i = 30 : 43
%    loc_rfiles{i} = [];
%     loc_rgb_grid_p{1}{i} = [];
%     loc_rgb_grid_x{1}{i} = []; 
% end


%% Save processed data
save_path = [data_path 'dataset.mat'];
save(save_path, 'loc_rfiles', 'loc_rsize', 'loc_dfiles');

save_path = [data_path 'rgb_corners.mat'];
save(save_path, 'loc_rgb_grid_p', 'loc_rgb_grid_x');

save_path = [data_path 'depth_plane_mask.mat'];
save(save_path, 'loc_depth_plane_poly', 'loc_depth_plane_mask');

end
