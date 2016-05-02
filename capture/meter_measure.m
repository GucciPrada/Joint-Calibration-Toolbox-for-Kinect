close all
clear all
clc

% distance measurement script

while(1)
    [rgb_img, d_img] = capture_kinect;
    meter = input('meter:');
    if isempty(meter)
        exit
    end
    
    imwrite();
end

