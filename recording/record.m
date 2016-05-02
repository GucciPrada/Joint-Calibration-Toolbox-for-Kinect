% Recording data to images/videos
close all
clear

% out_path = 'output/';
out_path = '../demo/B1/';

addpath('../capture/');
addpath('../../../lib/utility/');

% opt.use_winsdk = 1;
opt.use_libfreenect = 1;
% opt.highres = 1;

% Check un-assigned configuration
opt = check_exist_fileds(opt, {'use_winsdk', 'use_libfreenect', 'highres'});

img_ind = 14; % output file name starts from this index
set_ind = 0; % index of data set

global record_exit
record_exit = false; % detect Esc/'x' to exit

% % Fixme -- due to intensive computation of CPU/GPU using libfreenect,
% Indeed, mex wrapper for any library including libfreenect is not suitable for video recording
% Please refer to ROS OpenNI node which has the best performance so far
% make_avi = 0; % turn on to make video file

%% Test on real-time image data
addpath('../capture/'); % library of kinect API

h = figure(101);
set(gcf,'Position',[200 300 1500 500]);

% % Fixme
% if make_avi
%     rgb_aviobj = VideoWriter([out_path 'video/' sprintf('rgb_set%s.avi', num2str(set_ind))]);
%     dis_aviobj = VideoWriter([out_path 'video/' sprintf('dis_set%s.avi', num2str(set_ind))]);
%     rgb_aviobj.FrameRate = 10; dis_aviobj.FrameRate = 10;
%     
%     open(rgb_aviobj); open(dis_aviobj); % open stream
% end


while 1
    % obtain real-time data
    [rgb_img, imd]=capture_kinect(opt); % Detect space bar which may be used in triggering recording to continue
    if record_exit                      % Or Esc/'x' to exit recording
        fprintf('Recording done!\n');
        break;
    end
    % remap disparity data
    dis_img = remap_disparity(uint16(imd), 2047);
    
    fprintf('recording %d-th frame...\n', img_ind+1);
    
    % % Fixme
    %     if make_avi
    %         writeVideo(rgb_aviobj, rgb_img);
    %         writeVideo(dis_aviobj, im2double(imd));
    %     else
%     rgb_fout_name = [out_path 'pic/set' num2str(set_ind) '_' gen_frame_number(img_ind) '.jpg'];
%     dis_fout_name = [out_path 'pic/set' num2str(set_ind) '_' gen_frame_number(img_ind) '.pgm'];

%     rgb_fout_name = [out_path 'pic/' gen_frame_number(img_ind) '-c1.jpg'];
%     dis_fout_name = [out_path 'pic/' gen_frame_number(img_ind) '-d.pgm'];
    
    rgb_fout_name = [out_path gen_frame_number(img_ind) '-c1.jpg'];
    dis_fout_name = [out_path gen_frame_number(img_ind) '-d.pgm'];
    
    imwrite(rgb_img, rgb_fout_name, 'jpg');
    imwrite(dis_img, dis_fout_name, 'pgm', 'MaxValue', 2047);
    
    %     end
    
    img_ind = img_ind + 1;
end

% % Fixme
% if make_avi
%     close(rgb_aviobj);
%     close(dis_aviobj);
% end


