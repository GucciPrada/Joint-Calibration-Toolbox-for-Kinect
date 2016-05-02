%do_fixed_depth_calib()
% UI function
% Kinect calibration toolbox by DHC
function do_fixed_depth_calib()

%Outputs
global calib0

fprintf('-------------------\n');
fprintf('Using known values for initial depth camera calibration\n');
fprintf('-------------------\n');

calib0.dK = [  590 0  320;
         0  590 230;
         0  0    1];
calib0.dkc = [0 0 0 0 0];
calib0.depth_error_var = 3^2; %0.2324;
calib0.dR = eye(3);
calib0.dt = [-0.025 0 0]';

% Note: if we choose parameters from the original code, the depth values
% calculated from disparity calculated are arount 1e-5, which leads to 
% great cost betewen reprojected disparity points to measured ones.
calib0.dc = [3.0938 -0.0028]; %% By Wei Xiang
% calib0.dc = [ -0.0028525         1091]; %% By the original code

calib0.dc_alpha = [1,1];
calib0.dc_beta = zeros(480,640);