function [errors,image_mean,image_std]=get_depth_error_all2(calib, imd_dataset, depth_plane_mask)
  icount = length(imd_dataset);
  total_count = sum( cellfun(@(x) sum(x(:)), depth_plane_mask) );
  
  errors = zeros(total_count,1);
  
  image_mean = nan(1,icount);
  image_std = nan(1,icount);
  
  base = 1;
  for i=find(~cellfun(@isempty,imd_dataset))
    [points,disparity] = get_depth_samples2(imd_dataset{i},depth_plane_mask{i});
    if(size(points,2) == 0)
      continue;
    end
    
    error_i = get_depth_error(calib,points,disparity,calib.Rext{i},calib.text{i});
    image_mean(i) = mean(error_i);
    image_std(i) = std(error_i);
    
    errors(base:base+length(error_i)-1) = error_i;
    base = base+length(error_i);
  end;
  
  errors = errors(1:base-1); %Not all pixels in mask have disparity
end