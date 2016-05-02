function [ ret ] = detect_corners( ind, rgb, dx, win_dx, corner_count_x, corner_count_y )
global rgb_grid_p;
global rgb_grid_x;
global draw_rgb_corners

ret = 1;

p = click_ima_calib_rufli_k(ind, rgb, true, win_dx, win_dx, corner_count_x-1, corner_count_y-1);
if(isempty(p))
    warning('Corner finder was not able to detect checkerboard corners due to unclear target, please readjust');
    ret = 0;
    return;
end
[pp,xx,cx] = reorder_corners(p, dx);

if draw_rgb_corners
    draw corner
    figure(2);
    hold off;
    plot_rgb_corners2(rgb, pp);
    hold on;
    draw_axes(pp,cx);
    drawnow;
end
% store corner coordinates
rgb_grid_p{1}{ind} = pp; % since we only have one color camera, the first index will always be one
rgb_grid_x{1}{ind} = xx; % see original code for details

end

