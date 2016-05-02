depth_errors = []; ref_depth = [];
% errors_disp = []; ref_disp = [];
% Calculate rgb errors
% Calculate depth errors
for i = find(~cellfun(@isempty,depth_plane_mask))
    [points, disparity] = get_depth_samples(data_path, dfiles{i}, depth_plane_mask{i});
    if(isempty(disparity))
        continue;
    end
    u = points(1,:);
    v = points(2,:);
    xw = disparity2world(u, v, disparity, burrus_calib);
    [paxes] = princomp(xw');
    N = paxes(:,3);
    d = N' * mean(xw,2);
    
    xn = bsxfun(@rdivide, xw(1:2,:), xw(3,:));
    
    ref_depth_i = d ./ (sum(bsxfun(@times, xn, N(1:2)),1)+N(3));
    errors_depth_i = ref_depth_i - xw(3,:);
    %     ref_disp_i = depth2disparity(u,v,ref_depth_i,burrus_calib);
    %     errors_disp_i = ref_disp_i - disparity;
    
    depth_errors = [depth_errors, errors_depth_i];
    ref_depth = [ref_depth, ref_depth_i]; 
end
fprintf('Depth  : ');
[sigma,sigma_lower,sigma_upper] = std_interval(depth_errors,0.99);
fprintf('mean=%f, std=%f [-%f,+%f] (disparity)\n',mean(depth_errors),sigma,sigma_lower,sigma_upper);