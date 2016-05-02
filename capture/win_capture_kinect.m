clear; close all

% info = imaqhwinfo('kinect');
% info.DeviceInfo(1);

vid1 = videoinput('kinect',1, 'RGB_1280x960');
vid2 = videoinput('kinect',2, 'Depth_640x480');

% srcDepth = getselectedsource(vid2);
% % srcDepth.DepthMode = 'Near'; % not applicable in Matlab-2014Ra

vid1.FramesPerTrigger = 1;
vid2.FramesPerTrigger = 1;
vid1.TriggerRepeat = inf;
vid2.TriggerRepeat = inf;

triggerconfig([vid1 vid2],'manual');
start([vid1 vid2]);

h = figure;
set(gcf,'Position',[200 300 1500 500]);
set(h,'KeyPressFcn',{@figure_keypress}); % set callback

while 1
    % Trigger both objects.
    trigger([vid1 vid2])
    % Get the acquired frames and metadata.
    [rgb_img, ts_color, metaData_Color] = getdata(vid1);
    [dep_img, ts_depth, metaData_Depth] = getdata(vid2);
    
    subplot(1, 2, 1);
    imshow(rgb_img);
    subplot(1, 2, 2);
    imagesc(dep_img); axis image off
    
    % Detect keyboard stroke 'x', which meant to exit
    ret = get(gcf, 'UserData');
    if ischar(ret)
        set(gcf, 'UserData', []); % clear user data
        switch lower(ret)
            case 32
                win_kinect_quit(vid1, vid2);  % Must be called before calling kinect_mex again,
                                              % or Matlab will not stop previwing video object!
                break;
            case 'x'
                win_kinect_quit(vid1, vid2);
                break;
        end
    end
end


