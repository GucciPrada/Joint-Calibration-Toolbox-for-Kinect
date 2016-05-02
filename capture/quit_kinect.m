function quit_kinect( conf )

if conf.use_winsdk
    stop(conf.rgb_vid); delete(conf.rgb_vid); conf.rgb_vid = [];
    stop(conf.imd_vid); delete(conf.imd_vid); conf.imd_vid = [];
elseif conf.use_libfreenect
    kinect_mex('q');
else
    
end

end

