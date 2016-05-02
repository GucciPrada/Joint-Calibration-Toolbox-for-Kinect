%imd = read_disparity(filename)
% Reads a disparity image from disk. Corrects endianness issues. Replaces
% 'nan_value' values with NaNs. Default for nan_value is 2047.
%
% Kinect calibration toolbox by DHC
function imd = read_disparity(filename, nan_value, scale_min, scale_max)

% global read_depth

if(nargin < 3)
  nan_value = 2047;
  % correspond to 'dc = [3.3309495161 -0.0030711016];' % parameters recommended by Herrera
  scale_min = 678.0987; scale_max = 1002.6947;
end

use_custom_read = false;

[~,~,ext]=fileparts(filename);
if(strcmp(ext,'.pgm'))
  %PGM file, check for binary
  [fid,msg] = fopen(filename,'r');
  if(fid < 0)
    error('kinect_toolbox:read_disparity:fopen',strrep([filename ':' msg],'\','\\'));
  end
  
  magic = fscanf(fid,'%c',2);
  if(strcmp(magic,'P5'))
    %Binary pgm, use custom read to avoid matlab scaling
    use_custom_read = true;
  end
  fclose(fid);
end

if(use_custom_read)
  [imd,max_value]=readpgm_noscale(filename);
else
  imd = uint16(imread(filename));
  max_value = 65535;
end

%Check channel count
if(size(imd,3) > 1)
  warning('kinect_toolbox:read_disparity:channels','Disparity image has multiple channels, taking only first channel.');
  imd = imd(:,:,1);
end

%Check for little-endian and matlab scaling problems
if(nan_value==2047 && max(imd(:)) > 2047) %0x07FF
  imd_swap = swapbytes(imd);
  if(max(imd_swap(:)) <= 2047)
    %Fixed by swap
    imd = imd_swap;
  elseif(~use_custom_read)
    %We used matlabs imread, maybe matlab rescaled
    imd = imd / ((max_value+1)/2048);
  else
    warning('kinect_toolbox:read_disparity:max','Maximum disparity value is over 2047.');
  end
end

%Set invalid depths to NaN--cause we don't want to calculate on them!
%Setting them to any other value will bring so much noise for calibration
imd = double(imd);
imd(imd==nan_value) = nan;

% --depracated
% if read_depth
%     imd = imd / max_value;
%     imd = imd*(scale_max-scale_min+1) + scale_min - 1;
%     
%     % % debug
%     % % we can test whether for certain point, the depth remains same
%     % dc = [3.3309495161 -0.0030711016];
%     % t_dep = 1./(dc(2)*double(imd) + dc(1));
%     
%     imd = round(imd); % round values
% end