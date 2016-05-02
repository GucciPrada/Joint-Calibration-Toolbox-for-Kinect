%H=homography_from_corners(p,x)
% Builds a homography from two corresponding point lists. 
%
% p [2xP]
% x [2xP]
% H [3x3] p=H*x (up to scale)
%
% Kinect calibration toolbox by DHC
function H=homography_from_corners(p,x)

if(size(p,1) > 2)
  p = p(1:2,:) ./ repmat(p(3,:),2,1); % normalize Z coordinate
end
if(size(x,1) > 2)
  x = x(1:2,:); % take only (x,y) coodinates
end

count = size(p,2);
assert(count==size(x,2));

%Normalize by variance, which is good at skipping offsets of checkerboard
%for both p and x.
pm = mean(p,2);
pdist = mean( sum((p - repmat(pm,1,count)).^2,1).^0.5 );
pscale = 2^0.5/pdist;  % scale of p
                       % 2^0.5?:measurement unit, metre
Tp = [eye(2)*pscale, -pm*pscale; 0 0 1]; % normalizatin matrix via variance ()
% Tp = eye(3);
pn = Tp*[p; ones(1,count)]; % pn skipps offsets of checkerboard coodinates m (normalized)

xm = mean(x,2);
xdist = mean( sum((x - repmat(xm,1,count)).^2,1).^0.5 );
xscale = 2^0.5/xdist;  % scale of x
Tx = [eye(2)*xscale, -xm*xscale; 0 0 1]; % normalizatin matrix via variance
% Tx = eye(3);
xn = Tx*[x; ones(1,count)]; % xn skipps offsets of checkerboard coodinates M (normalized)

%Constraints--different from paper
% based on: P_z*Py=P_x*Pz ('_' indicates obtained data, and calculated p from Homography, if without '_')
%           P_z*Px=P_y*Pz
A = zeros(2*count,9);
for i=1:count
  A(i*2-1, 4:6) = -pn(3,i)*xn(:,i)';
  A(i*2-1, 7:9) = pn(2,i)*xn(:,i)';

  A(i*2, 1:3) = pn(3,i)*xn(:,i)';
  A(i*2, 7:9) = -pn(1,i)*xn(:,i)';
end

[~,~,v] = svd(A);
h = v(:,end); % the last column is the solution to Lx=0 (notations from the paper)
Hn = reshape(h,[3,3])'; % h = [h11 h12 h13 h21 h22 h23 h31 h32 h33];
                        % after reshape:   h = [h11 h21 h31
                        %                       h12 h22 h32
                        %                       h13 h23 h33]
                        % after transpose: h = [h11 h12 h13
                        %                       h21 h22 h23
                        %                       h31 h31 h33]

H = inv(Tp)*Hn*Tx; % measurement unit transformation of homography, from Tx to Tp:
                   % Tx*Hn=Tp*H, thus, H=inv(Tp)*Hn*Tx, 
                   % cause H is defined up to a scale
H = H/norm(H(:,1)); % normalize against the norm 2 of first column in H