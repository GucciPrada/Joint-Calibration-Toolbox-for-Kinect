function write_yml_reg( filename, reg_data )
%It should look like this:
% %YAML:1.0
% R: !!opencv-matrix
%    rows: 3
%    cols: 3
%    dt: f
%    data: [ 1., 0., 0., 0., 1., 0., 0., 0., 1. ]
% T: !!opencv-matrix
%    rows: 3
%    cols: 1
%    dt: f
%    data: [ 0., 0., 0. ]

fid=fopen(filename,'w+');
fprintf(fid,'%%YAML:1.0\n');
write_mat(fid, 'ref_pix_size', reg_data.reference_pixel_size);
write_mat(fid, 'ref_distance', reg_data.reference_distance);
write_mat(fid, 'raw_to_mm_shift', reg_data.raw_to_mm_shift);
fclose(fid);
end

function write_mat(fid,name,m)
  fprintf(fid,'%s: !!opencv-matrix\n',name);
  fprintf(fid,'   rows: %d\n',size(m,1));
  fprintf(fid,'   cols: %d\n',size(m,2));
  fprintf(fid,'   dt: f\n');
  fprintf(fid,'   data: [ ');
  
  data = m';
  data = data(:);
  
  max_per_line = 4;
  line_count = ceil(length(data)/max_per_line);
  for l = 1:line_count-1
    base = (l-1)*max_per_line+1;
    if(l > 1)
      fprintf(fid,'      ');
    end
    fprintf(fid,' %f,',data(base:base+max_per_line-1));
    fprintf(fid,'\n');
  end
  l = line_count;
  
  base = (l-1)*max_per_line+1;
  if(l > 1)
    fprintf(fid,'      ');
  end
  if(base < length(data))
    fprintf(fid,' %f,',data(base:end-1));
  end
  
  fprintf(fid,' %f',data(end));
  
  fprintf(fid,' ]\n');
end
