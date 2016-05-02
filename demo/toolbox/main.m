
close all
clearvars -global % clear also global data if you want, evertime it will startover
clear
clc

global dataset_path % directory which saves all the captured images
global debug_cnt
debug_cnt = 0;
global draw_rgb_corners
draw_rgb_corners = 0;

addpath('../../recording');
addpath('../../../../lib/utility');

recalc_calib = 1;   % recalculate calibration parameters
dataset_name = 'A1';
calib_filepath = ['../calib_ret2/calib_' dataset_name '.mat'];   % default path to save calibration results
                                                % change it to different names if you
                                                % want to compare between datasets
capture_option.use_libfreenect = 1; % use_libfreenect/use_winsdk
capture_option.highres = 0; % applicable in both models

capture_option = check_exist_fileds(capture_option, {'use_winsdk', 'use_libfreenect', 'highres'});

% %%%%%%%%%%%%  'read_depth' flag depracated  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % dataset_read_depth_flag = {0, 1}; % flags that indicate whether dataset were originally converted from depth data
% global read_depth
% read_depth = 0;             % read disparity that originally converted from depth data
% if capture_option.use_winsdk
%     read_depth = 1;
% end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

use_depth_dkc = 1;  % calibrate depth geometric distortion
use_depth_distortion = 1; % correct kinect 'myopic' distortion

imd_width = 640; imd_height = 480;

global rfiles rsize dfiles
global rgb_grid_p rgb_grid_x
global depth_corner_p depth_corner_x
global depth_plane_poly depth_plane_mask
    
% capture_data(output_path);

print_info();

disp('--------------------------------------------------')
disp('Please select source of input data ([]=2):');
disp('1) from existing dataset');
disp('2) take data instantly (make sure your Kinect is connected)');
disp('Be aware: all the intermediate data during calibration process will be deleted!');
disp('          Be sure to follow all the steps carefully!');

user_in = input('>');
if isempty(user_in)
    user_in = 0;
end
switch user_in
    case 1
        capture_data = 0; % way to retrieve data
        disp('--------------------------------------------------')
        disp(['Path of all input file (see attached document for all the requirements of input data) ([]=''../' dataset_name '/'')']);
        dataset_path = input('>', 's');
        if isempty(dataset_path)
            dataset_path = ['../' dataset_name '/'];
        end
%         if strcmp(dataset_name, 'A1')
%             read_depth = 0;
%         else
%             read_depth = 1;
%         end
    case {2, 0}
        capture_data = 1;
        disp('--------------------------------------------------')
        disp(['Path of directory where all intermediate data will be dumped ([]=''../' dataset_name '/'')']);
        dataset_path = input('>', 's');
        if isempty(dataset_path)
            dataset_path = ['../' dataset_name '/']; % all intermediate data will be dumped here
        end
        oris = {'f', 'x', 'y', 'a'}; % orientations [4]
        pic_num = 10; % number of pictures for each orientation [4]
        wall_num = 0; % number of pictures taken in front of a wall [5]
        total_pic = length(oris) * pic_num + wall_num;
    otherwise
        error('Invalid input!');
end


global_vars % loading and initializing all global values
global final_calib final_calib_error

if capture_data == 1 % retrieving data online
    rgb_grid_p = cell(1, 1); rgb_grid_p{1} = cell(1, total_pic);
    rgb_grid_x = cell(1, 1); rgb_grid_x{1} = cell(1, total_pic);
    depth_corner_p{1} = cell(1, total_pic);
    depth_corner_x{1} = cell(1, total_pic);
    depth_plane_poly = cell(1, total_pic);
    depth_plane_mask = cell(1, total_pic);
    rgb_dataset = cell(1, total_pic);
    imd_dataset = cell(1, total_pic);
    
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Check capture runtime for Kinect, including:
    %           1. Retrieve Mex of Libfreenect Wrapper
    %           2. Detect Kinect in Matlab
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    check_capture_runtime(capture_option);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Parameter Configuration...
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp('--------------------------------------------------');
    % use automatic corner detector
    disp('Default to using automatic corner detector...');
    % select pattern dimensions
    sqr_def = 0.031;
    dx = input(['Square size ([]=' num2str(sqr_def) 'm): ']);
    if(isempty(dx))
        dx = sqr_def;
    end
    % select corner counters
    cnt_x_def = 10; % 10 with Wei's Checkerboard
    cnt_y_def = 7; % 7 with Wei's Checkerboard
    corner_count_x = input(['Inner corner count in X direction ([]=' num2str(cnt_x_def) '): ']); 
    corner_count_y = input(['Inner corner count in Y direction ([]=' num2str(cnt_y_def) '): ']);
    if(isempty(corner_count_x))
        corner_count_x = cnt_x_def;
    end
    if(isempty(corner_count_y))
        corner_count_y = cnt_y_def;
    end
    % select search window dimensions
    if capture_option.highres 
        win_def = 6;
    else
        win_def = 3;
    end
    % default to 6 when using 1280 * 1024 image, therefore, we choose 3 for 640*480 images
    win_dx = input(['Corner finder window size ([]=' num2str(win_def) 'px): ']);
    if(isempty(win_dx))
        win_dx = win_def;
    end
    
    if draw_rgb_corners
        figure(1);
        clf;
        figure(2);
        clf;
    end
    figure(3);
    clf;
    
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Capturing... 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp('--------------------------------------------------');
    disp('Make sure you are doing as instructed below:');
    disp('When you are ready at position, press ''space'' to proceed');
    disp('--------------------------------------------------');
    disp('Showing real-time data stream...');
    fprintf('\t\t\tpress ''space'' to capture data\n'); % at the same time, stop stream
                                                        % data captured corresponds to its format, i.e., disparity or depth.
    fprintf('\t\t\tpress ''d'' to switch between disparity/depth\n');
    fprintf('\t\t\tpress ''x'' to skip\n');

    cnt = 1; % image index
    for i = 1 : length(oris)
        
        if i == 1
            disp('Please put calibration board in front of camera, then move at various distances');
        elseif i < 4
            fprintf('Please rotate calibration board around %s-coordinate, then move at various distances\n', oris{i});
        else
            disp('Please put calibration board at any orietations, then move at various distances');
        end
        
        j = 1;
        while j <= pic_num
            [rgb, imd] = capture_kinect(capture_option);
%             imd = format_disparity(imd); --Fixme
            
            % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Detect corners... 
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            ret = detect_corners(cnt, rgb, dx, win_dx, corner_count_x, corner_count_y);
            if ret == 0
                continue;
            end
            
            % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Detect calibration planes... 
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            select_plane(cnt, imd_width, imd_height, imd);
            
            % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Store dataset... 
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            rgb_dataset{cnt} = rgb;
            imd_dataset{cnt} = imd;
            
            % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Store temporary corner detection results, in case your labeling work in vain...
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            do_save_tmp_calib(dataset_path, rgb, imd, cnt-1); % by overwrite existing mat file
                                                      % write images indexed from 0
            
            j = j + 1;
            cnt = cnt + 1;         
        end
    end

%     disp('Please put calibration board in front of wall, then move at various distances');
%     for i = 1 : wall_num
%         [rgb, imd] = capture_kinect(capture_option);
% %         imd = format_disparity(imd); --Fixme
%         depth_plane_mask{cnt} = logical(ones(imd_height, imd_width));
%         % store only the depeth image for wall
%         imd_dataset{cnt} = imd;
%         
%         % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         % Store temporary corner detection results, in case your labeling work in vain...
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         do_save_tmp_calib(dataset_path, rgb, imd, cnt-1); % by overwrite existing mat file
%                                                   % write images indexed from 0
%         cnt = cnt + 1;
%     end

    % debug
    get_wall_images('../wall/', dataset_path, cnt-1); 
    
    
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Recover temporary data for future use of offline calibration and 
    % create masks for wall images
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    recover_tmp_calib(dataset_path);
    
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %           Calibration
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    do_calib_online(imd_dataset, ...
        rgb_dataset, use_depth_dkc, use_depth_distortion );
    
    
    
else % retrieving data from specified directory
        
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %           Calibrationn-- offline
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if recalc_calib == false
        if exist(calib_filepath, 'file') == 2
            load(calib_filepath);
            
            % print calibration results loaded
            fprintf('Loading calibration results:\n');
            print_calib(final_calib, final_calib_error);
            print_calib_stats(final_calib);
        else
            warning('No avaliable calibration result found!');
        end
        return;
    else
        do_calib_offline(use_depth_dkc, use_depth_distortion);
    end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Save Calibration Results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[pathstr, name, ext] = fileparts(calib_filepath);
if ~exist(pathstr, 'dir')
    mkdir(pathstr);
end

% saving calibration result with certain suffix for debug
name_suffix = [];
if use_depth_distortion
    name_suffix = [name_suffix '_beta'];
else
    name_suffix = [name_suffix '_no_beta'];
end
if use_depth_dkc
    name_suffix = [name_suffix '_dkc'];
else
    name_suffix = [name_suffix '_no_dkc'];
end

% save the calibration data as both mat file and yml file(provided by the author)
filename = fullfile(pathstr, [name name_suffix '.mat']);
% save(filename, 'final_calib', 'final_calib_error');--not preferable
do_save_calib(filename);
filename = fullfile(pathstr, [name name_suffix '.yml']);
save_calib_yml(filename, final_calib, rsize);

% print the calibration results
fprintf('Calibration finished.\n');
print_calib(final_calib, final_calib_error);
if capture_data % online calibration
    print_calib_stats2(final_calib, imd_dataset);
else % offline calibration
    print_calib_stats(final_calib);
end



% is_validation = false; % preserved for dataset testing

