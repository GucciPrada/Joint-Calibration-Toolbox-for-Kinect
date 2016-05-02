function [ frustum ] = read_frustum( path )

raw = dlmread(path, ' ');
num_v = raw(1,1);
num_u = raw(1,2);
bin_size = raw(1,3);

frustum = raw(2:end,:);
frustum = frustum(:);

frustum = reshape(frustum, [num_v num_u bin_size]);

end

