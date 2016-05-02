clc; clear; close all;

data_path = '../A3/';
ret_path = '../calib_ret/';

name = 'calib_A3_beta_dkc';
calib_filepath = [ret_path name '.mat'];

if exist(calib_filepath, 'file') == 2
    load(calib_filepath);
    print_calib(final_calib, final_calib_error);
    fprintf('Herrera''s stat for %s:\n', name);
    print_calib_stats(final_calib);
else
    warning('No avaliable calibration result found!');
end

%% Burrus's method
% reg_data = read_yaml([ret_path 'burrus_freenect_1.17433.yaml']);
% burrus_calib = burrus_reg_data_export(reg_data);
% burrus_calib.Rext = final_calib.Rext;
% burrus_calib.text = final_calib.text;
% burrus_calib.dc = final_calib.dc; % if not modified, transformation will be messy
% print_calib_stats(burrus_calib);

% fprintf('Burrus''s stat:\n');
% [rgb_errors]=get_rgb_errors(burrus_calib);
% for k = 1:length(rgb_errors)
%     [sigma,sigma_lower,sigma_upper] = std_interval(rgb_errors{k},0.99);
%     fprintf('Color %d: mean=%f, std=%f [-%f,+%f] (pixels)\n',k,mean(rgb_errors{k}),sigma,sigma_lower,sigma_upper);
% end
% burrus_depth_error
%    

%% B2


    %% For dataset A1


%% For dataset A3 & A4 (A3 without wall images)
% % A3
% Color 1: mean=0.010068, std=0.706550 [-0.024524,+0.026268] (pixels)
% Depth  : mean=0.033944, std=0.923592 [-0.001316,+0.001320] (disparity)
% % A4
% Color 1: mean=0.009528, std=0.673641 [-0.023382,+0.025045] (pixels)
% Depth  : mean=0.070371, std=0.982356 [-0.001400,+0.001404] (disparity)
