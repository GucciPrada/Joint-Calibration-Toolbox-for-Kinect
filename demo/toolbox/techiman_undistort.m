function [ zd_s ] = techiman_undistort( z_s, u_s, v_s, frustum )

[num_v num_u num_bins] = size(frustum);

bin_width = 8;
bin_height = 6;
bin_depth = 2;

zd_s = zeros(1, length(z_s));

for i = 1 : length(z_s)
    u = u_s(i);
    v = v_s(i);
    z = z_s(i);
    
    idx = min([num_bins, ceil(z / bin_depth)]);    
%     idx = min([num_bins-1, floor(z / bin_depth)]);

    start = (idx-1) * bin_depth;
    if (z - start < bin_depth / 2)
        idx1 = idx;
    else
        idx1 = idx + 1;
    end
    idx0 = idx1 - 1;
    
%     if (idx0 < 0 || idx1 >= num_bins || counts_(idx0) < 50 || counts_(idx1) < 50)
%         undistort(z);
%         continue;
%     end

    z0 = (idx0 + 1) * bin_depth - bin_depth * 0.5;
    coeff1 = (z - z0)/bin_depth;
    coeff0 = 1.0 - coeff1;
    
    v_ind = floor(v / bin_height) + 1;
    u_ind = floor(u / bin_width) + 1;
    
    mult = coeff0 * frustum(v_ind, u_ind, idx0+1) + coeff1 * frustum(v_ind, u_ind, idx1+1);

    zd_s(i) = z * mult;
end


end

