function capture_data( output_path )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%           Capture Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global cnt
cnt = 0; % name the file by starting from this index

if ~ispc
    
    addpath('../capture');
    
    if ~(exist('kinect_mex')==3),
        fprintf('compiling the mex file... (probably need to change path names to get this to work!)\n');
        % NOTE probably need to change path names... % -I/usr/local/include
        %       /Users/aberg/work/kinect/new_kinect/libusb/libusb/.libs/libusb-1.0.0.dylib ...
        % -Dchar16_t=uint16_t
        %      -I/Users/sean/Kinect/libfreenect-master/build/lib/libfreenect.0.4.2.dylib ...
        %       ...
        % -l/Users/sean/Kinect/libfreenect-master/build/lib/libfreenect_sync.0.4.2.dylib ...
        
        mex   -I/Users/sean/Kinect/libfreenect-master/include ...
            "/Users/sean/Kinect/libfreenect-master/build/lib/libfreenect.0.4.2.dylib" ...
            "/Users/sean/Kinect/libfreenect-master/build/lib/libusb-1.0.0.dylib" ...
            kinect_mex.cc
    end
    
    
    figure(1);
    colormap gray
    set(gcf,'Position',[200 300 640 960]);
    
    
    tic;
    kinect_mex(); % get first data...
    kinect_mex('R');
    
        
    while 1
        [a,b]=kinect_mex();
        
        % show disparity image (in raw disparity unit by OpenKinect)
        subplot(2,1,1);
        dis_img = permute(reshape(a,[640,480]),[2 1]);
        % map from set {0,1,...,2047} to set {0,1,...,maxval}
        dis_img = remap_disparity(dis_img, 2047);
        hd = imshow(dis_img);
        
        % show color image
        subplot(2,1,2);
        if (length(b)>307200)
            rgb_img = permute(reshape(b,[3,640,480]),[3 2 1]);
            hc = imshow(rgb_img);
        else
            rgb_img = repmat(permute(reshape(b,[640,480]),[2 1]),[1 1 3]);
            hc = imshow(rgb_img);
        end
        
        set(hd,'ButtonDownFcn',{@ImageClickCallback, output_path, rgb_img, dis_img});
        set(hc,'ButtonDownFcn',{@ImageClickCallback, output_path, rgb_img, dis_img});
        
        % Detect right click and exit
        ret = get(gcf, 'UserData');
        if strcmpi(ret, 'alt')
            break;
        end
        
        drawnow;
        
    end
    
else

end % end of usingMac

close all;



end

