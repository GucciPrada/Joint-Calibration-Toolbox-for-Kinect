clear, close all

addpath(genpath('../../../../lib/utility'));

dataset_name = 'A1';
validate_dataset_name = 'B1';
load_calib_file = ['calib_' dataset_name '_beta_dkc'];
use_depth_dkc = 1;
use_depth_distortion = 1;

n_img_start_num = 10; % number of images needs to be calibrated
n_rand_test = 100; % number of random tests

global_vars

is_validation = true;

%% Obtain indice of rgb and disparity images respectively
file_names = getAllFiles(['../' dataset_name '/']);
rgb_cnt = 1; imd_cnt = 1;
for i = 1 : length(file_names)
    [~, names{i}, ext{i}] = fileparts(file_names{i});
    if ext{i} == '.pgm'
        imd_file_names{imd_cnt} = [names{i} ext{i}];
        imd_ind(imd_cnt) = sscanf(names{i}, '%d-d');
        imd_cnt = imd_cnt + 1;
    elseif ext{i} == '.jpg'
        rgb_file_names{rgb_cnt} = [names{i} ext{i}];
        rgb_ind(rgb_cnt) = sscanf(names{i}, '%d-c1');
        rgb_cnt = rgb_cnt + 1;
    else
        continue;
    end
    
end

max_n_imgs = max(max(rgb_ind), max(imd_ind)); % for A1 validated in B1
% max_n_imgs = max(length(rgb_ind), length(imd_ind)); % for A2 validated in B2
img_bins = 10:10:max_n_imgs;

% %% Calibration based on Random Tests
% for m = img_bins
%     
% %     mean_color_error = zeros(n_rand_test, 1); mean_depth_error = zeros(n_rand_test, 1);
% %     std_color_error = zeros(n_rand_test, 1); std_depth_error = zeros(n_rand_test, 1);
%     
%     for k = 1 : n_rand_test
%         
%         do_load_calib(['../calib_ret/' load_calib_file]);
%         
%         %% Obtain certain number of random indice to calibrate
%         
%         rand_img_num = randperm(max_n_imgs, m) - 1; % index starts from 0
%         
%         %% Calibration
%         % initialize temporary data, which will overwrite the original ones
%         t_depth_plane_mask = [];
%         t_dfiles = [];
%         t_rfiles = cell(1);
%         t_rgb_grid_p = cell(1);
%         t_rgb_grid_x = cell(1);
%         
%         for i = 1 : m
%             num = rand_img_num(i);
%             if any(rgb_ind == num) && ~any(imd_ind == num) % rgb exists, disparity not
%                 t_rfiles{1}{end+1} = rgb_file_names{rgb_ind == num};
%                 t_rgb_grid_p{1}{end+1} = rgb_grid_p{1}{rgb_ind == num};
%                 t_rgb_grid_x{1}{end+1} = rgb_grid_x{1}{rgb_ind == num};
%                 t_depth_plane_mask{end+1} = [];
%                 t_dfiles{end+1} = [];
%             elseif ~any(rgb_ind == num) && any(imd_ind == num) % disparity exists, rgb not
%                 t_rfiles{1}{end+1} = [];
%                 t_rgb_grid_p{1}{end+1} = [];
%                 t_rgb_grid_x{1}{end+1} = [];
%                 t_depth_plane_mask{end+1} = depth_plane_mask{imd_ind == num};
%                 t_dfiles{end+1} = imd_file_names{imd_ind == num};
%             else % both exist
%                 t_rfiles{1}{end+1} = rgb_file_names{rgb_ind == num};
%                 t_rgb_grid_p{1}{end+1} = rgb_grid_p{1}{rgb_ind == num};
%                 t_rgb_grid_x{1}{end+1} = rgb_grid_x{1}{rgb_ind == num};
%                 t_depth_plane_mask{end+1} = depth_plane_mask{imd_ind == num};
%                 t_dfiles{end+1} = imd_file_names{imd_ind == num};
%             end
%         end
%         
%         calib0 = [];
%         final_calib = [];
%         final_calib_error = [];
%         depth_plane_mask = t_depth_plane_mask;
%         dfiles = t_dfiles;
%         rfiles = t_rfiles;
%         rgb_grid_p = t_rgb_grid_p;
%         rgb_grid_x = t_rgb_grid_x;
%         
%         do_calib_offline(use_depth_dkc, use_depth_distortion);
%         
%         % print the calibration results
%         %     fprintf('Calibration result on random test #%d with chosen %d images\n', k, n_img_start_num);
%         %     print_calib(final_calib, final_calib_error);
%         %     print_calib_stats(final_calib);
%         
%         %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %  Save Calibration Results
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         save_calib_file = ['../calib_ret2/calib_' dataset_name sprintf('_rand_test_%d_nimg_%d', k, m)];
%         [pathstr, name, ext] = fileparts(save_calib_file);
%         if ~exist(pathstr, 'dir')
%             mkdir(pathstr);
%         end
%         
%         % saving calibration result with certain suffix for debug
%         name_suffix = [];
%         if use_depth_distortion
%             name_suffix = [name_suffix '_beta'];
%         else
%             name_suffix = [name_suffix '_no_beta'];
%         end
%         if use_depth_dkc
%             name_suffix = [name_suffix '_dkc'];
%         else
%             name_suffix = [name_suffix '_no_dkc'];
%         end
%         
%         % save the calibration data as both mat file and yml file(provided by the author)
%         filename = fullfile(pathstr, [name name_suffix '.mat']);
%         % save(filename, 'final_calib', 'final_calib_error');--not preferable
%         do_save_calib(filename);
%         filename = fullfile(pathstr, [name name_suffix '.yml']);
%         save_calib_yml(filename, final_calib, rsize);
%         
% %         %% Validation
% %         % loading calibrated data from this path:
% %         %     calib_file = '../calib_ret/calib_B1_beta_dkc.mat';
% %         % loading validation data from this path:
% %         base_path = '../calib_ret/';
% %         do_load_calib([base_path 'calib_' validate_dataset_name name_suffix  '.mat']);
% %         
% %         fprintf('Random test #%d with chosen %d images\n', k, m);
% %         filename = fullfile(pathstr, [name name_suffix '.mat']);
% %         [mean_color_error(k), mean_depth_error(k), std_color_error(k), std_depth_error(k)] = do_validate(filename);
%     end
%     
% %     fprintf('------------------------------------------\n');
% %     fprintf('After %d random tests on %d images:\n', n_rand_test, m);
% %     fprintf('Color: mean=%f, std=%f (pixels)\n', mean(mean_color_error), mean(std_color_error));
% %     fprintf('Depth: mean=%f, std=%f (disparity)\n', mean(mean_depth_error), mean(std_depth_error));
% %     fprintf('------------------------------------------\n');
% 
% end


%% Validation based on Random Tests

% m_cnt = 1; 
% for m = img_bins
%     k_cnt = 1;
%     
%     for k = 1 : n_rand_test
%        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %  Load Calibration Results
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         load_calib_file = ['../calib_ret2/calib_' dataset_name sprintf('_rand_test_%d_nimg_%d', k, m)];
%         [pathstr, name, ext] = fileparts(load_calib_file);
%         % saving calibration result with certain suffix for debug
%         name_suffix = [];
%         if use_depth_distortion
%             name_suffix = [name_suffix '_beta'];
%         else
%             name_suffix = [name_suffix '_no_beta'];
%         end
%         if use_depth_dkc
%             name_suffix = [name_suffix '_dkc'];
%         else
%             name_suffix = [name_suffix '_no_dkc'];
%         end
%         
%        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %  See calibration stats
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         do_load_calib(fullfile(pathstr, [name name_suffix '.mat']));
%         [calib_mean_color_error(m_cnt, k_cnt), calib_mean_depth_error(m_cnt, k_cnt), ...
%             calib_std_color_error(m_cnt, k_cnt), calib_std_depth_error(m_cnt, k_cnt)] = print_calib_stats3(final_calib);
%        
%         
%        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %  Validation
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         % loading validation data from this path:
%         do_load_calib(fullfile(pathstr, ['calib_' validate_dataset_name name_suffix '.mat']));
%         % validation on the following dataset:
%         fprintf('Random test #%d with chosen %d images\n', k, m);
%         [test_mean_color_error(m_cnt, k_cnt), test_mean_depth_error(m_cnt, k_cnt), ...
%             test_std_color_error(m_cnt, k_cnt), test_std_depth_error(m_cnt, k_cnt)] = do_validate(fullfile(pathstr, [name name_suffix '.mat']));
% 
%         k_cnt = k_cnt + 1;
%     end
% 
%     m_cnt = m_cnt + 1;
% end
% 
% save(['../calib_ret2/rand_bf_ret_' validate_dataset_name '.mat'], 'test_mean_color_error', 'test_mean_depth_error', 'test_std_color_error', 'test_std_depth_error');
% save(['../calib_ret2/rand_calib_ret_' dataset_name '.mat'], 'calib_mean_color_error', 'calib_mean_depth_error', 'calib_std_color_error', 'calib_std_depth_error');



%% Validation
load('../calib_ret/rand_test_ret_B1.mat');
% Remove and approximate outliers
outlier_ind = test_std_depth_error > 2;
test_std_depth_error(outlier_ind) = nan;
%% Validation Stats--ANOVA
[p,tbl,stats] = anova1(test_std_depth_error');
p
% For B1, p-value = 0.1297
% For B2, p-value < 0.0001


%% Validation Stats--best and average performance
% 
h = figure;
hold on
[min_std_depth, ~]= nanmin(test_std_depth_error, [], 2);
x = (10:max_n_imgs)'; y = min_std_depth;
f = fit(x, y,'poly2','Normalize','on','Robust','Bisquare');
fh{1}= plot(f, 'k', x, y, '-g');
% legend([], );    

mean_std_depth= nanmean(test_std_depth_error, 2);
x = (10:max_n_imgs)'; y = mean_std_depth;
f = fit(x, y,'poly2','Normalize','on','Robust','Bisquare');
fh{2}= plot(f, 'r', x, y, '-b');
ylim([0.80 1.05]);
legend([fh{1}(1) fh{1}(2) fh{2}(1) fh{2}(2)], 'Best performance', 'Fitted: Best performance', ...
    'Average performance', 'Fitted: Average performance');    
xlabel('Number of calibration images'); ylabel('std. dev. of disparity error (kdu)');
title('Performance in random tests');
pubgraph(h,14,2,'w');

% if ispc
%     export_fig('C:\Users\xw_11_000\Dropbox\research\iWORK\SIGCHI2015LaTex\figures\herrera_best_avg_test_B2', '-pdf', '-nocrop', h);
% elseif isunix
%     export_fig('/home/wei/Dropbox/research/iWORK/SIGCHI2015LaTex/figures/herrera_best_avg_test_B2', '-pdf', '-nocrop', h);
% end
% hold off

%% Validation Stats--Boxplot
% num_img_list = [10 20 30 40 50];
% x = [];
% for i = 1 : length(num_img_list)
%     num_img = num_img_list(i);
%     x = [x, test_std_depth_error(num_img-10+1,:)']; % image number starts from 10
% end
% 
% h = figure;
% boxplot(x, 'labels',{'10','20','30','40','50'},'whisker',1); 
% title('Performance in random tests')
% xlabel('Number of calibration images')
% ylabel('std. dev. of disparity error (kdu)')
% pubgraph(h,14,2,'w');
% if ispc
%     export_fig('C:\Users\xw_11_000\Dropbox\research\iWORK\SIGCHI2015LaTex\figures\herrera_boxplot_B1', '-pdf', '-nocrop', h);
% elseif isunix
%     export_fig('/home/wei/Dropbox/research/iWORK/SIGCHI2015LaTex/figures/herrera_best_boxplot_B1', '-pdf', '-nocrop', h);
% end

%% Draw Calibration Stats
% load('../calib_ret/rand_calib_ret_A3.mat');
% outlier_ind = calib_std_depth_error > 2;
% calib_std_depth_error(outlier_ind) = nan;
% 
% h = figure;
% [calib_std_depth, ~]= nanmin(calib_std_depth_error, [], 2);
% x = (10:max_n_imgs)'; y = calib_std_depth;
% f = fit(x, y,'poly2','Normalize','on','Robust','Bisquare');
% fh{1}= plot(f, 'r', x, y, '-b');
% ylim([0.6 1.4]);
% legend([fh{1}(1) fh{1}(2)], 'Minimal calibration error', 'Fitted: Minimal calibration error');    
% % plot(10:60, calib_std_depth, 'DisplayName', 'Herrera''s Method');
% xlabel('Number of calibration images'); ylabel('std. dev. of disparity error (kdu)');
% title('A2');
% pubgraph(h,14,2,'w');
% export_fig('C:\Users\xw_11_000\Dropbox\research\iWORK\SIGCHI2015LaTex\figures\herrera_best_calib_A2', '-pdf', '-nocrop', h);
% 
% calib_std_depth= nanmean(calib_std_depth_error, 2);
% x = (10:max_n_imgs)'; y = calib_std_depth;
% f = fit(x, y,'poly2','Normalize','on','Robust','Bisquare');
% fh{1}= plot(f, 'r', x, y, '-b');
% ylim([0.6 1.4]);
% legend([fh{1}(1) fh{1}(2)], 'Average calibration error', 'Fitted: Average calibration error');    
% % plot(10:60, calib_std_depth, 'DisplayName', 'Herrera''s Method');
% xlabel('Number of calibration images'); ylabel('std. dev. of disparity error (kdu)');
% title('A2');
% pubgraph(h,14,2,'w');
% export_fig('C:\Users\xw_11_000\Dropbox\research\iWORK\SIGCHI2015LaTex\figures\herrera_avg_calib_A2', '-pdf', '-nocrop', h);