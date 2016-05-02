function check_capture_runtime( capture_option )

global dataset_path
addpath(genpath('../../capture/'));

if nargin < 1
    capture_option = [];
end

% Check un-assigned configuration
capture_option = check_exist_fileds(capture_option, {'use_winsdk', 'use_libfreenect', 'highres'});

if capture_option.use_winsdk
    info = imaqhwinfo('kinect');
    info.DeviceInfo(1);
    if isempty(info.DeviceIDs)
        error('No Kinect device found in Matlab, please install Windows Kinect SDK first\n');
    end
elseif capture_option.use_libfreenect
%     if capture_option.highres
%         error('High resolution RGB image (1280X960) is only available in using Windows Kinect SDK\n');
%     end
    mex_name = [];     % detect mex file used to capture data stream
    if ispc % windows
        mex_name = 'kinect_mex.mexw64';
    elseif ismac % mac
        mex_name = 'kinect_mex.mexmaci64';
    else % linux
        mex_name = 'kinect_mex.mexa64';
    end
    if exist(mex_name, 'file') ~= 3 % mex type file does not exist
        prev_fold = pwd;
        cd('../../capture/');
        if compile_mex(mex_name) == 0
            error('No mex file found! Please compile your mex file manually\n');
        end
        cd(prev_fold);
    end
else
    warning('Kinect_toolbox: Kinect runtime not supported!');
end


% deleting all intermediate data first
if ~exist(dataset_path, 'dir')
    mkdir(dataset_path);
end
%     delete([dataset_path '*.*']);


end

