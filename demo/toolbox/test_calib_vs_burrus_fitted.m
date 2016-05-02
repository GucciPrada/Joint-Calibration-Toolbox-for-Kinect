%%
clear
close all

ret_path = '../calib_ret/';
data_path = '../A2/';

do_load_calib([ret_path 'calib_A2_beta_dkc.mat']);
reg_data = read_yaml([ret_path 'burrus_freenect_1.17433.yaml']);

global dfiles
global depth_plane_mask
global final_calib

calib = final_calib;

calib.dc = [3.3309495161 -0.0030711016]; % use recommended setting by Herrera

errors_disp={[] []};
ref_disp={[] []};
errors_depth={[] []};
ref_depth={[] []};
ref_beta=[];


for i=find(~cellfun(@isempty,depth_plane_mask))
    [points,disparity]=get_depth_samples(data_path, dfiles{i},depth_plane_mask{i});
    if(isempty(disparity))
        continue;
    end
    u = points(1,:);
    v = points(2,:);
    
    %Distortion beta
    ind = sub2ind(size(calib.dc_beta),v+1,u+1);
    ref_beta_i = calib.dc_beta(ind);
    ref_beta = [ref_beta,ref_beta_i];
    
    %Raw errors
    xw = disparity2world(u,v,disparity,calib);
    
    [paxes] = princomp(xw');
    N = paxes(:,3);
    d = N' * mean(xw,2);
    
    xn = bsxfun(@rdivide, xw(1:2,:), xw(3,:));
    
    ref_depth_i = d ./ (sum(bsxfun(@times, xn, N(1:2)),1)+N(3));
    errors_depth_i = ref_depth_i - xw(3,:);
    
    ref_disp_i = depth2disparity(u,v,ref_depth_i,calib);
    errors_disp_i = ref_disp_i - disparity;
    
    errors_depth{1} = [errors_depth{1}, errors_depth_i];
    ref_depth{1} = [ref_depth{1}, ref_depth_i];
    errors_disp{1} = [errors_disp{1}, errors_disp_i];
    ref_disp{1} = [ref_disp{1}, ref_disp_i];
    
    %% Export Burrus's reg data
    burrus_calib = burrus_reg_data_export(reg_data);
    xw = disparity2world(u,v,disparity,burrus_calib);
    
    [paxes] = princomp(xw');
    N = paxes(:,3);
    d = N' * mean(xw,2);
    
    xn = bsxfun(@rdivide, xw(1:2,:), xw(3,:));
    
    ref_depth_i = d ./ (sum(bsxfun(@times, xn, N(1:2)),1)+N(3));
    errors_depth_i = ref_depth_i - xw(3,:);
    
    ref_disp_i = depth2disparity(u,v,ref_depth_i,burrus_calib);
    errors_disp_i = ref_disp_i - disparity;
    
    errors_depth{2} = [errors_depth{2}, errors_depth_i];
    ref_depth{2} = [ref_depth{2}, ref_depth_i];
end


%% Generate histograms
dataset_labels = {'Herrera C.''s method','Burrus''s method'};
bins = 64;

hist_std = zeros(3,bins);
count = zeros(3,bins);

marker = '.+o';
color = 'rb';

hold on ZZ
for k=1:2
    step = (max(ref_depth{k})-min(ref_depth{k}))/bins;
    limit = min(ref_depth{k}):step:max(ref_depth{k});
    for i=1:bins
        valid = ref_depth{k} >=limit(i) & ref_depth{k} < limit(i+1); %& abs(ref_beta)<=0.5;
        if(sum(valid) < 50)
            hist_std(k,i) = nan;
        else
            data = errors_depth{k}(valid);
            hist_std(k,i) = nanstd(data);
            count(k,i) = sum(~isnan(data));
        end
    end
    
    %     % Remove Outlier -- Not applicable!
    %     n = 2;
    %     hist_vec = hist_std(k,:);
    %     hist_vec(hist_vec>(mean(hist_vec)+n*std(hist_vec)))=[];    
    
    %% Fit polygon
    x = limit(1:bins);
    y = hist_std(k,:);
    w = count(k,:); w(:)=1;
    valid = ~isnan(y); x=x(valid); y=y(valid); w=w(valid);
    
    fo = fitoptions('Method','NonlinearLeastSquares',...
        'Lower',[0,0],...
        'Upper',[Inf,max(x)],...
        'StartPoint',[1 1]);
    ft = fittype('a*(x-b)^n','problem','n','options',fo);
    
    exclude_pts = y > mean(y)+2*std(y);
%     f = fit(x', y'*1e+3, 'poly2');
    f = fit(x', y'*1e+3, ft,'problem', 2, 'Exclude', exclude_pts);
    h{k}= plot(f, color(k), x', y'*1e+3, [marker(k) color(k)], exclude_pts, 'xr');
    
    xeval = min(x):0.1:max(x);
% %     plot(xeval,polyval(p,xeval)*1e+3,['-' color(k)],'DisplayName', ['Fitted: ' dataset_labels{k}], 'LineWidth', 2);
end


%% After experiments, we found fitting a curve is not a good idea for comparison, since
    % The fitted curves are too close to each other.
    
legend([h{1}(1) h{2}(1) h{1}(3) h{2}(3) h{1}(2)],'Data: Herrera''s method', 'Data: Burrus''s method',...
    'Fitted: Herrera''s method', 'Fitted: Burrus''s method', 'Outlier');
set(h{1}(3), 'LineWidth', 2); set(h{2}(3), 'LineWidth', 2);
set(h{1}(1), 'MarkerSize', 15); set(h{2}(1), 'MarkerSize', 10);
% the following are for reference:
% legend([h{1}(1) h{2}(1)],'Data: Herrera''s method', 'Data: Burrus''s method');
% legend([h{1}(2) h{2}(2)],'Outlier: Herrera''s method', 'Outlier: Burrus''s method');
% legend([h{1}(3) h{2}(3)],'Fitted: Herrera''s method', 'Fitted: Burrus''s method');

