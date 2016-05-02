%do_rgb_depthmap()
% UI function.
% Kinect calibration toolbox by DHC
function do_rgb_depthmap2(rgb_filepath, depth_filepath)

global rsize final_calib

if(isempty(final_calib))
  fprintf('Must perform calibration first.\n')
  return
end

filename = depth_filepath;
if(isempty(dir(filename)))
  fprintf('File not found.');
  return
end

imd = read_disparity(filename);


depthmap = compute_rgb_depthmap(imd, final_calib);

%Show pure depthmap so that it can be stored
imtool(depthmap,[]);

%Find rgb file
rfilename = rgb_filepath;
if(isempty(dir(rfilename)))
  fprintf('File not found.\n');
  return
end
im = imread(rfilename);

%Show superposition of depth map and rgb
figure(1);
clf;
imshow(im);
hold on;
h = imshow(mat2gray(depthmap));
set(h, 'AlphaData', 0.4);
