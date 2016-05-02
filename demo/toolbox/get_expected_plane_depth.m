function ref_w = get_expected_plane_depth(points,calib,Rext,text)
  %Get expected values
  [rN,rd] = extrinsic2plane(Rext,text); % rN: unit normal of calibration plane
                                        % rd: distance of calibration plane z to origin
%   disp(text);
  % dot operation calculates relative translation of depth camera to color camera after 
  % rotation, which is then projected to the normal of calibration plane.
  % plus distance of z coordinate of calibration plane to origin.
%   dd = dot(-calib.dR'*calib.dt,rN) + rd;  % v2.1
  dd = rd - dot(calib.dt,rN); % v2.2
    
  
  % trace ray direction
  xn = get_dpoint_direction(points(1,:),points(2,:),calib);

  
  % dN: relative rotation * unit normal of calibration plane
  %   = how much angle of z coordinate in image coordinates of depth camera 
  %     needs to be rotated to color camera
  dN = calib.dR'*rN;

  
  % dN(1)*xn(1,:)+dN(2)*xn(2,:)+dN(3): restore from depth image coordinates
  % to color image coordinates for z
  
  % (restored color world distance in z) / (restored color image coordinate z)
  %  = depth in meter
  ref_w = dd ./ (dN(1)*xn(1,:)+dN(2)*xn(2,:)+dN(3));
end