function do_useful_fcn()
fprintf('\n');
fprintf('--- Kinect Calibration Toolbox ---\n');
fprintf('\n');
fprintf('The following functions are not in the GUI but they might be useful for your calibration:\n');
fprintf('  global_vars - Loads the toolbox global variables into the current workspace. Run this to access the calibration results.\n');
fprintf('  do_save_calib - Saves the calibration input (corners & planes) data and results.\n');
fprintf('  do_load_calib - Loads the calibration input (corners & planes) data and results.\n');
fprintf('  save_calib_yml - Saves the calibration in YAML format so that it can be loaded from C++.\n');
fprintf('\n');
fprintf('  depth2disparity - Transforms a depth value (meters) to a disparity value (kinect disparity units).\n');
fprintf('  disparity2depth - Transforms a disparity value (kinect disparity units) to a depth value (meters).\n');
fprintf('  disparity2world - Transforms a pixel coordinate [u,v,d] (pixels and kinect disparity units) to world units (meters).\n');
fprintf('  compute_rgb_depthmap - Transforms a kinect disparity image to a depth map registered to the color image.\n');
fprintf('\n');
fprintf('  plot_rgb_corners - Plots the extracted corners for a color image.\n');
fprintf('  plot_rgb_reprojection - Plots the corners and their reprojection for a color image.\n');
fprintf('  plot_rgb_errors - Plots a summary of the reprojection errors for all color images.\n');
fprintf('\n');
fprintf('  plot_depth_reprojection - Plots the reprojection of the disparity values for a given depth image.\n');
fprintf('  plot_depth_image_errors - Plots a histogram of the reprojection errors for each depth images.\n');
fprintf('  plot_depth_errors - Plots a summary of the reprojection errors for all depth images.\n');
fprintf('\n');
fprintf('  print_calib_color - Prints the calibrated values for the color cameras.\n');
fprintf('  print_calib_depth - Prints the calibrated values for the depth camera.\n');
fprintf('  print_calib - Prints the calibrated values.\n');
fprintf('  print_calib_stats - Prints the error statistics for the current calibration and data set.\n');
fprintf('  print_calib_stats - Prints the error statistics for the current calibration and one image.\n');
fprintf('\n');
fprintf('  do_validate - Once calibrated, use this to validate your results on a separate dataset.\n');
fprintf('  do_select_depth_corners - Selects plane corners in the depth image to use estimate an initial calibration.\n');
fprintf('  do_initial_depth_calib - Estimates an initial calibration for the depth camera using known initial values or user selected corners.\n');
fprintf('\n');
fprintf('If you use the toolbox for your research, please cite the relevant paper.\nVisit the website for the full reference.\n');
fprintf('Toolbox website: http://www.ee.oulu.fi/~dherrera/kinect/\n');
fprintf('\n');


% added!!!
% do_rgb_depthmap()

