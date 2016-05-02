function [rgb_img, d_img] = capture_kinect( option )

% % debug
% global glb_min glb_max
% glb_min = inf; glb_max = 0;

global record_exit % invoked by 'record' to detect exit command


% Check un-assigned configuration
option = check_exist_fileds(option, {'use_winsdk', 'use_libfreenect', 'highres'});

if nargin < 1
    if ispc % windows user use winsdk by default-- requires 'Matlab Image Data Acquisition' toolbox
        option.use_winsdk = true;
        option.highres = true;
    else % user of other platforms use libfreenect by default
        option.use_libfreenect = true;
        option.highres = true;
    end
end

% addpath(genpath('../../../lib/utility/'));
addpath(genpath('../../../lib/kinect_toolbox/'));

if option.highres
    rgb_width = 1280; rgb_height = 1024;
else
    rgb_width = 640; rgb_height = 480;
end
depth_width = 640; depth_height = 480;

% kinect initialization
if option.use_winsdk
    % info = imaqhwinfo('kinect');
    % info.DeviceInfo(1);
    if option.highres
        vid1 = videoinput('kinect',1, 'RGB_1280x960');
    else
        vid1 = videoinput('kinect',1, 'RGB_640x480');
    end
    option.rgb_vid = vid1; % store object of color stream for destruction
    vid2 = videoinput('kinect',2, 'Depth_640x480');
    option.imd_vid = vid2; % store object of depth stream for destruction
    % srcDepth = getselectedsource(vid2);
    % % srcDepth.DepthMode = 'Near'; % not applicable in Matlab-2014Ra
    vid1.FramesPerTrigger = 1;
    vid2.FramesPerTrigger = 1;
    vid1.TriggerRepeat = inf;
    vid2.TriggerRepeat = inf;
    triggerconfig([vid1 vid2],'manual');
    start([vid1 vid2]);
elseif option.use_libfreenect
    kinect_mex(); % get first data...
    kinect_mex('R'); % showing RGB data
end

show_depth = 0; % switch off to show raw disparity map

% dc = [2.3958 -0.0022]; % parameters trained by Herrera's method--A1 dataset
dc = [3.3309495161 -0.0030711016]; % parameters recommended by Herrera
    
h = figure(101);
set(gcf,'Position',[200 300 1500 500]);

set(h,'KeyPressFcn',{@figure_keypress}); % set callback
% disp('--------------------------------------------------');
% disp('Showing real-time data stream...');
% fprintf('\t\t\tpress ''d'' to switch between disparity/depth\n');
% fprintf('\t\t\tpress ''space'' to capture data\n'); % at the same time, exit
%                             % data captured corresponds to its format, i.e.,
%                             % disparity or depth.
% fprintf('\t\t\tpress ''x'' to stop at any time\n');

while 1
    % obtain real-time data
    if option.use_winsdk % windows kinect runtime
        % Trigger both objects.
        trigger([vid1 vid2])
        % Get the acquired frames and metadata.
        rgb_img = fliplr(getdata(vid1));
        d_img = fliplr(getdata(vid2)); % depth in mm
        d_img = double(d_img)./1000; % depth in m
        imd  = dep2imd(d_img, dc);
    else % libfreenect
        [a, b]=kinect_mex();
        % return double type disparity image
        imd = double(permute(reshape(a,[depth_width, depth_height]),[2 1])); 
%         if (length(b)>307200)
%             rgb_img = permute(reshape(b,[3,rgb_width,rgb_height]),[3 2 1]);
%         else
%             rgb_img = repmat(permute(reshape(b,[rgb_width,rgb_height]),[2 1]),[1 1 3]);
%         end
        rgb_img = permute(reshape(b,[3,rgb_width,rgb_height]),[3 2 1]);
    end
    
%     if show_depth && ~option.use_winsdk % we can't transform from depth to disparity without
%                                         % considering distortion pattern
%         d_img = 1./(dc(2)*double(imd) + dc(1));
%     else
%         d_img = imd;
%     end

    if show_depth
        d_img = 1./(dc(2)*double(imd) + dc(1));
    else
        d_img = imd;
    end
    
    figure(h); % make figure current
    % plot
    subplot(1, 2, 1);
    imshow(rgb_img);
    title('RGB');
    
    subplot(1, 2, 2);
    if show_depth
        imshow(d_img);
    else
        imshow(im2uint8(mat2gray(d_img)));
    end
    set(gcf,'colormap',jet);

%     if show_depth || (~show_depth && option.use_winsdk)
%         title('Depth');
%     else
%         title('Disparity');
%     end
    if show_depth
        title('Depth');
    else
        title('Disparity');
    end    
    drawnow; % re-draw
    
    
    ret = get(gcf, 'UserData');
    if ischar(ret)
        set(gcf, 'UserData', []);     % clear user data
        switch lower(ret)
            case {27, 'x'}            % Detect keyboard stroke 'x'/Esc, which meant to exit
                
                quit_kinect(option);  % Must be called before calling kinect_mex next time,
                                      % or Matlab will crash/be unable to capture again!
                if ~isempty(record_exit)
                    record_exit = 1;
                end
                break;
            case 32                       % When recording, triggering spacebar to forward
                if ~isempty(record_exit)  % When we use capture_kienct in online calibration,
                    record_exit = 0;      % trigger space bar will continue to corner detection
                                          % without closing the device
                end
                break;
            case 'd'                  % transform display/returning data between disparity and depth
                if option.use_winsdk
%                     warning('kinect_toolbox:capture_kinect', ...
%                         'Transfomation between disparity and depth is not supported using windows kinect sdk!');
                end
                show_depth = ~show_depth;

        end
    end
end

end

