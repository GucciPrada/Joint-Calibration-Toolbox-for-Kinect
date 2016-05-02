function [ calib ] = teichman_reg_data_export( )
% Fields of calib and final_calib:
% 	rK {K}[fx 0 u0; 0 fy v0; 0 0 1] intrinsics for rgb camera K
% 	rkc {K}[1x5] distortion coefficients for rgb camera K
% 	rR {K}[3x3] rotation matrix from camera K to camera 1 (r1X = rR{k} * rkX + rt{k})
% 	rt {K}[3x1] translation vector from camera K to camera 1 (r1X = rR{k} *	rkX + rt{k})
% 	dK [fx 0 u0; 0 fy v0; 0 0 1] intrinsics for depth camera
% 	dkc [1x5] distortion coefficients for depth camera
% 	dc [1x2] coefficients for disparity-depth function
%   dc_alpha [3x1] distortion decay coefficients for the disparity-depth function
%   dc_beta [480x640] distortion per-pixel coefficients for the disparity-depth function
% 	dR [3x3] relative rotation matrix (r1X = dR * dX + dt)
% 	dt [3x1] relative translation vector (r1X = dR * dX + dt)
% 	Rext {N}[3x3] cell array of rotation matrices grid to camera 1
%             one for each image (r1X = Rext * gridX + text)
% 	text {N}[3x1] cell array of translation vectors grid to camera 1
%             one for each image (r1X = Rext * gridX + text)


calib.rK{1} = [];               %Color camera intrinsics matrix
calib.rkc{1} = [];              %Color camera distortion coefficients
calib.rR{1} = eye(3);               %Rotation matrix depth camera to color camera (first is always identity)
calib.rt{1} = zeros(3,1);               %Translation vector depth camera to color camera (first is always zero)
calib.color_error_var = [];  %Error variance for color camera corners

calib.dK = [  590 0  320; %Depth camera intrinsics matrix
    0  590 230;
    0  0    1];
calib.dkc = [0 0 0 0 0]; %Depth camera distortion coefficients


calib.dc = [3.3309495161 -0.0030711016];             % Depth camera depth2disparity coefficients
                                                     % recommended by Herrera

calib.dc_alpha = [];         %Depth camera depth2disparity coefficients
calib.dc_beta = [];          %Depth camera depth2disparity coefficients
calib.depth_error_var = [];  %Error variance for disparity
calib.dR = eye(3);           %Rotation matrix depth camera to color camera
calib.dt = [-0.025 0 0]';    %Translation vector depth camera to color camera
calib.Rext = [];             %Cell array of rotations world to color camera
calib.text = [];             %Cell array of translations world to color camera

end

