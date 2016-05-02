
function ImageClickCallback ( src , evt, output_basepath, rgb_img, dis_img )

global cnt 

buttonclick = get(gcf,'SelectionType');


switch lower(buttonclick)
    case 'normal' % left click
        % output both color and depth image when click button
        addpath(genpath('./pgm_toolbox/'));
        fout_name = [output_basepath gen_frame_number(cnt) '-c1' '.jpg'];
        imwrite(rgb_img, fout_name, 'jpg');
        fout_name = [output_basepath gen_frame_number(cnt) '-d' '.pgm'];
        
        % when we do imwrite with max value 2048, the image matrix will be
        % scaled down automatically, which leads to a certain ratio when we
        % want to use imread for scaling in readpnm (in imread) to have a
        % better illustration...
        
        % the disparity image we got is correct, however, the imwrite
        % writes datdou'b'la to 63 at maximum...
        
        imwrite(dis_img, fout_name, 'pgm', 'MaxValue', 2047);
        %         pnmwritepnm(dis_img, [], fout_name, 'MaxValue', 2048);
        
        fprintf('recording data to %s\n', fout_name);
        
        cnt = cnt + 1;
        
    case 'alt' % right click
        kinect_mex('q');
        set(gcf, 'UserData', buttonclick); % return click type by setting 'UserData'
    otherwise
end

end
