%[N,d]=fit_plane(X)
% Finds the best fit plane for a set of points using PCA.
% return  the calibration plane parameters (normal and distance from origin).
% Kinect calibration toolbox by DHC
function [N,d]=fit_plane(X)
  if length(find(isnan(X))) ~= 0
      X(isnan(X)) = 0;
  end
  center = mean(X,2);
  vecs = princomp(X');

  N = vecs(:,3);
  d = dot(N,center);
end