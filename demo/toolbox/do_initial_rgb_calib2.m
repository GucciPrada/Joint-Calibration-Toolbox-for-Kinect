%do_initial_rgb_calib()
% UI function
% Kinect calibration toolbox by DHC--Modified by WeiXiang
function do_initial_rgb_calib2(use_fixed_init, rgb_dataset)

%Inputs
global rgb_grid_p rgb_grid_x
%Outputs
global calib0

%Check previous steps
if(isempty(rgb_grid_p))
  do_select_rgb_corners();
end

fprintf('-------------------\n');
fprintf('Initial RGB camera calibration\n');
fprintf('-------------------\n');

ccount = length(rgb_grid_p);

Rext = cell(1,ccount);
text = cell(1,ccount);
kc0 = zeros(1,5);

%Independent camera calibration
for k = 1:length(rgb_grid_p)
  fprintf('Color camera #%d\n',k);

  %Compute homographies for rgb images
  rcount = 1; % number of color camer = 1

  if(use_fixed_init)
    %Use fixed internal matrix to determine extrinsics
    %Load one image
    im = rgb_dataset{1};
    
    %This is not a proper focal length estimate, but it works with the
    %kinect.
    rKc = [size(im,2), 0, size(im,2)/2; 
            0, size(im,2), size(im,1)/2;
            0,0,1];

    rRc = cell(1,rcount);
    rtc = cell(1,rcount);
    for i=find(~cellfun(@(x) isempty(x),rgb_grid_p{k}))
      H = homography_from_corners(rgb_grid_p{k}{i},rgb_grid_x{k}{i});
      [rRc{i},rtc{i}] = extrinsics_from_homography(rKc,H);
    end
  else
    %Estimate intrinsics and extrinsics using homographies
    rH = cell(1,rcount);
    for i=find(~cellfun(@(x) isempty(x),rgb_grid_p{k}))
      rH{i} = homography_from_corners(rgb_grid_p{k}{i},rgb_grid_x{k}{i});
    end

    %Closed form calibration using homographies
    [rKc,rRc,rtc]=calib_from_homographies(rH);
    rKc(1,2) = 0; %No skew
  end
  
  %Refine calibration using all images for this camera
  [calib0.rK{k},calib0.rkc{k},Rext{k},text{k},calib0.color_error_var(k),~] = rgb_calib(rKc,kc0,rRc,rtc,rgb_grid_p{k},rgb_grid_x{k},false);

  %Point camera forwards
  for i=find(~cellfun(@(x) isempty(x),Rext{k}))
    if(text{k}{i}(3) < 0)
      Rext{k}{i}(:,1:2) = -Rext{k}{i}(:,1:2);
      text{k}{i} = -text{k}{i};
    end
  end
  
  if(k==1)
    %First color camera is the reference frame
    calib0.Rext = Rext{1};
    calib0.text = text{1};
    calib0.rR{1} = eye(3);
    calib0.rt{1} = zeros(3,1);
    
    %All images must be present
    if(any(cellfun(@(x) isempty(x),calib0.Rext)))
      warning('kinect_toolbox:do_initial_rgb_calib:empty_calib0_Rext','Not all images are present for camera #1.');
    end
  else
    %Other cameras are relative to first
    rR = zeros(3,rcount); % rR {K}[3x3] rotation matrix from camera K to camera 1 
    rt = zeros(3,rcount); % rt {K}[3x1] translation vector from camera K to camera 1
    for i=find(~(cellfun(@(x) isempty(x),Rext{k}) | cellfun(@(x) isempty(x),calib0.Rext)))
      Ri = calib0.Rext{i}*Rext{k}{i}'; % r1X = rR{k} * rkX + rt{k}
      rR(:,i) = rotationpars( Ri );
      rt(:,i) = calib0.text{i} - Ri*text{k}{i};
    end
    calib0.rR{k} = rotationmat( mean(rR,2) );
    calib0.rt{k} = mean(rt,2);

    %Fill in Rext entries where camera 0 is not valid.
    for i=find(~cellfun(@(x) isempty(x),Rext{k}) & cellfun(@(x) isempty(x),calib0.Rext))
      calib0.Rext{i} = calib0.rR{k}*Rext{k}{i};
      calib0.text{i} = calib0.rt{k} + calib0.rR{k}*text{k}{i};
    end
  end
end

if(ccount > 1)
  %Joint RGB-calibration
  fprintf('Joint RGB camera calibration\n');
  options = calibrate_kinect_options();
  options.use_fixed_dK = true;
  options.use_fixed_dkc = true;
  options.use_fixed_dc = true;
  options.use_fixed_rRt = false;
  options.use_fixed_pose = false;

  options.use_fixed_rK = false;
  options.use_fixed_rkc = [false false false false false];
  options.use_fixed_dR = true;
  options.use_fixed_dt = true;
  options.use_fixed_dc_alpha = true;

  % when setting all parameters to depth/color option as 'fixed', means the
  % calibration procesdure will be done on another type of camera, i.e.:
  % use_color = ~(options.use_fixed_rK && all(options.use_fixed_rkc) && options.use_fixed_pose);
  % use_depth = ~(options.use_fixed_dK && all(options.use_fixed_dkc) && all(options.use_fixed_dc) && options.use_fixed_dR && options.use_fixed_dt && options.use_fixed_pose) && ~isempty(depth_plane_disparity);


  % As from above parameter setting, all 'd' related parameters are fixed,
  % then it intends to do the calibration for color camera.
  [params1]=calibrate_kinect(options,rgb_grid_p,rgb_grid_x,{},{},calib0);
  calib0=params1;
end

%Print calibration results
for k = 1:length(rgb_grid_p)
  fprintf('\nInitial calibration for camera %d:\n',k);
  
  print_calib_color(k,calib0);
  
  %Reproject
  error_abs=[];
  error_rel=[];
  for i=find(~cellfun(@(x) isempty(x),rgb_grid_p{k}))
    X = rgb_grid_x{k}{i};

%     p_abs = project_points_k(X,calib0.rK{k},calib0.rkc{k},Rext{k}{i},text{k}{i});
%     errori = p_abs-rgb_grid_p{k}{i};
%     errori = sum(errori.^2,1).^0.5;
%     error_abs = [error_abs, errori];
    
    % take relative pose from external to color into consideration
    R = calib0.rR{k}'*calib0.Rext{i};
    t = calib0.rR{k}'*(calib0.text{i} - calib0.rt{k});
    
    p_rel = project_points_k(X,calib0.rK{k},calib0.rkc{k},R,t);
    errori = p_rel-rgb_grid_p{k}{i};
    
%     errori = sum(errori.^2,1).^0.5;
%     error_rel = [error_rel, errori];
    error_rel = [error_rel; errori(:)];
  end
  %fprintf('Mean reprojection error with absolute Rt: %f\n',mean(error_abs));
  fprintf('Reprojection error std. dev.: %f\n',std(error_rel));
end