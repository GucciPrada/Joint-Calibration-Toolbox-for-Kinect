function imd = format_disparity(imd)
nan_value = 2047;
imd = uint16(imd);
max_value = 65535;

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

%Set invalid depths to NaN
imd = double(imd);
imd(imd==nan_value) = NaN;