% Visualize calibration results
close all
clear

% addpath(genpath('../../../../lib/utility/'));
addpath(genpath('../../../../lib/kinect_toolbox/'));


base_path = '../A3/';
calib_filepath = '../calib_ret/calib_A3_beta_no_dkc';

capture_option.use_winsdk = 1;
capture_option.highres = 1;

% Check un-assigned configuration
capture_option = check_exist_fileds(capture_option, {'use_winsdk', 'use_libfreenect', 'highres'});

if capture_option.highres
    rgb_width = 1280; rgb_height = 1024;
else
    rgb_width = 640; rgb_height = 480;
end
depth_width = 640; depth_height = 480;

% calib_filepath = [base_path 'final_calib'];

addpath('export_fig/'); % for output figure data

testing_realdata = 1; % turn on to capture real data
add_noncalib_comparison = 1; % turn on to add comparison for non-calibrated results

global cnt; % output file name starts from this index
cnt = 0;

if exist([calib_filepath '.mat'], 'file') == 2
    load(calib_filepath);
    % print the calibration results
    fprintf('Loading calibration results:\n');
    print_calib(final_calib, final_calib_error);
    
    
    if ~testing_realdata
        %% Test on single image
        file_ind = '0020';
        imd = read_disparity([base_path file_ind '-d.pgm']);
        tStart = tic;
        % visualize calibration resuls
        calib_depth_img = compute_rgb_depthmap(double(imd), final_calib);
        tElapsed = toc(tStart)
        
        
        rgb_img = imresize(imread([base_path file_ind '-c1.jpg']), [480 640]);
        
        % show superposition of depth map and rgb
        h = figure(100);
        
        plot_calib_result(rgb_img, imd, calib_depth_img, ...
            add_noncalib_comparison, final_calib);
        
        % output result image
        fout_name = ['../output/train_' gen_frame_number(cnt) '.jpg'];
        export_fig(fout_name, '-jpg', h);
        %         cnt = cnt + 1;
        
        
    else
        %% Test on real-time image data
        addpath('../../capture/'); % library of kinect API

        h = figure(101);
        set(gcf,'Position',[200 300 1500 500]);
        
        while 1
            % obtain real-time data
%             [a, b, reg]=kinect_mex();
            [a, b]=kinect_mex();
            % return double type disparity image
            imd = double(permute(reshape(a,[depth_width, depth_height]),[2 1]));
            rgb_img = permute(reshape(b,[3,rgb_width,rgb_height]),[3 2 1]);
            
            tStart = tic;
            % visualize calibration resuls
            [calib_depth_img, calib_depth_img_filled]= compute_rgb_depthmap_v2(rgb_img, ...
                                        double(imd), final_calib, size(rgb_img));
            tElapsed = toc(tStart)
            
            %             imd = visualize_disparity(double(imd));
            
            plot_calib_result(rgb_img, imd, calib_depth_img_filled, ...
                add_noncalib_comparison, final_calib);
            
            % assign callback
            set(h,'KeyPressFcn',{@VisualizeCalibCallback, '../output/', h});

            drawnow;
            
            % Detect keyboard stroke 'x', which meant to exit
            ret = get(h, 'UserData');
            if ~isempty(ret)
                switch lower(ret)
                    case 32
                    case 'd'
                        show_depth = ~show_depth;
                    case 'x'
                        kinect_mex('q');
                        break;
                end
                set(gcf, 'UserData', []); % clear user data
                
            end
            
        end
    end
    
else
    warning('No avaliable calibration result file!');
end
