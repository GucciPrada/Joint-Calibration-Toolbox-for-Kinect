function print_calib_stats2(calib, imd_dataset, rgb_errors, depth_errors)

global depth_plane_mask
if(~exist('depth_errors','var') || isempty(rgb_errors))
    [rgb_errors]=get_rgb_errors(calib);
end
for k = 1:length(rgb_errors)
    [sigma,sigma_lower,sigma_upper] = std_interval(rgb_errors{k},0.99);
    fprintf('Color %d: mean=%f, std=%f [-%f,+%f] (pixels)\n',k,mean(rgb_errors{k}),sigma,sigma_lower,sigma_upper);
end

fprintf('Depth  : ');
if(~exist('depth_errors','var'))
    depth_errors = get_depth_error_all2(calib, imd_dataset, depth_plane_mask);
end
[sigma,sigma_lower,sigma_upper] = std_interval(depth_errors,0.99);
fprintf('mean=%f, std=%f [-%f,+%f] (disparity)\n',mean(depth_errors),sigma,sigma_lower,sigma_upper);

end