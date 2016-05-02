function plot_rgb_corners2(rgb, p)
  count = size(p,2);
  
  imshow(rgb,'InitialMagnification','fit');

  hold on;
  plot(p(1,:)+1, p(2,:)+1, 'r+','DisplayName','Selected corners');
  title('Corners detected');
  
  s = cell(1,count);
  for j=1:count
    %s{j} = sprintf('#%d\n(%.3f,%.3f)',j,x(1,j),x(2,j));
    s{j} = sprintf('%d',j);
  end
  h=text(p(1,:)-3, p(2,:)-3,s);
  set(h,'color','red');
  
  min_x = min(p(1,:))-6;
  max_x = max(p(1,:))+6;
  min_y = min(p(2,:))-6;
  max_y = max(p(2,:))+6;
  axis([min_x max_x min_y max_y]);
end