function [points,disparity]=get_depth_samples2(imd_dataset, masks)
  icount = length(imd_dataset);
  
  points = cell(1,icount);
  disparity = cell(1,icount);
  
  for i=1:icount
    if(isempty(imd_dataset{i}))
      points{i} = zeros(2,0);
      disparity{i} = zeros(1,0);
    else
      imd = imd_dataset{i};

      [points{i}(2,:),points{i}(1,:)] = ind2sub(size(masks{i}),find(masks{i})');
      points{i} = points{i}-1; %Zero based
      disparity{i} = imd(masks{i})';
    end
  end

end