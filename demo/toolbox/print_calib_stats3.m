function [mean_color_error, mean_depth_error, std_color_error, std_depth_error] = print_calib_stats3(calib, rgb_errors, depth_errors)

if(~exist('depth_errors','var') || isempty(rgb_errors))
    [rgb_errors]=get_rgb_errors(calib);
end
for k = 1:length(rgb_errors)
    [sigma,sigma_lower,sigma_upper] = std_interval(rgb_errors{k},0.99);
    fprintf('Color %d: mean=%f, std=%f [-%f,+%f] (pixels)\n',k,mean(rgb_errors{k}),sigma,sigma_lower,sigma_upper);
end

std_color_error = sigma;

fprintf('Depth  : ');
if(~exist('depth_errors','var'))
    global dataset_path dfiles depth_plane_mask
    depth_errors = get_depth_error_all(calib,dataset_path,dfiles,depth_plane_mask);
end
[sigma,sigma_lower,sigma_upper] = std_interval(depth_errors,0.99);
fprintf('mean=%f, std=%f [-%f,+%f] (disparity)\n', mean(depth_errors),sigma,sigma_lower,sigma_upper);

std_depth_error = sigma;


mean_color_error = mean(rgb_errors{k});
mean_depth_error = mean(depth_errors);


end