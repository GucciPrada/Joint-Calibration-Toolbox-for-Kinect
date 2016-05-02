clear
clc


%% Compile Mex file
os = lower(computer);
mex_name = [];
if ispc % windows
    mex_name = 'kinect_mex.mexw64';
elseif ismac % mac
    mex_name = 'kinect_mex.mexmaci64';
else % linux
    mex_name = 'kinect_mex.mexa64';
end
% os = strrep(os, 'pcwin', 'w'); % if in windows OS, format string
% os = strrep(os, 'pcwin', 'w'); % if in windows OS, format string
% mex_name = sprintf('kinect_mex.mex%s', os);


if exist(mex_name, 'file') ~= 3 % mex type file does not exist
    ret = compile_mex(mex_name);
    if ret == 0
        error('No mex file found!\n');
    end
end

%% Test on capturing data stream
capture_kinect;
