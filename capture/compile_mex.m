function ret = compile_mex(mex_name)

ret = 1;

if ispc % windows
    
%     %----windows 7 machine
%     %***** "pthreads" include ************
%     libfreenect_ipath = fullfile('D:','Kinect', 'lib', 'libfreenect-master', 'include', filesep);
%     libfreenect_lpath = fullfile('D:','Kinect', 'build_0.1.2', 'x64', 'Debug', filesep);
%     %***** "pthreads" include and library************
%     phtreads_ipath = fullfile('D:','Kinect', 'lib', 'pthreads-w32-2-8-0-release', 'Pre-built.2', 'include', filesep);
%     phtreads_lpath = fullfile('D:','Kinect', 'lib', 'pthreads-w32-2-8-0-release', 'Pre-built.2', 'lib', filesep);
%     %***** "unistd" include and library************
%     uni_lpath = fullfile('D:','Kinect', 'lib', 'libfreenect-master', 'platform', 'windows', filesep);
%     %***** "glut" include and library************
%     glut_ipath = fullfile('D:','Kinect', 'lib', 'glut-3.7.6-bin', filesep);
%     glut_lpath = fullfile('D:','Kinect', 'lib', 'glut-3.7.6-bin', 'GL', filesep);
%     
    
    %----windows 8.1 machine
      %***** "pthreads" include ************
    libfreenect_ipath = fullfile('D:','Kinect', 'lib', 'libfreenect', 'include', 'libfreenect', filesep);
    libfreenect_lpath = fullfile('D:','Kinect', 'lib', 'libfreenect', 'build', 'x64', 'Debug', filesep);
    %***** "pthreads" include and library************
    phtreads_ipath = fullfile('D:','Kinect', 'lib', 'pthreads-w32-2-8-0-release', 'Pre-built.2', 'include', filesep);
    phtreads_lpath = fullfile('D:','Kinect', 'lib', 'pthreads-w32-2-8-0-release', 'Pre-built.2', 'lib', filesep);
    %***** "unistd" include and library************
    %     uni_lpath = fullfile('D:','Kinect', 'lib', 'libfreenect-master', 'platform', 'windows', filesep);
    %***** "glut" include and library************
    glut_ipath = fullfile('D:','Kinect', 'lib', 'glut-3.7.6-bin', filesep);
    glut_lpath = fullfile('D:','Kinect', 'lib', 'glut-3.7.6-bin', filesep);
%     %***** "libyaml" include and library************ deprecated
%     libyaml_ipath = 'yaml-0.1.5/include'; % relative path
%     libyaml_lpath = 'yaml-0.1.5/win32/vs2008/Output/Debug/lib'; % relative path
    %***** "libusb" include and library************
%     libusb_ipath = fullfile('D:','Kinect', 'lib', 'libusb_patched_x64', filesep);
    libusb_lpath = fullfile('D:','Kinect', 'lib', 'libusb_patched_x64', 'x64', 'Debug', 'dll', filesep);    
    
    mex('-largeArrayDims', ['-I' libfreenect_ipath], ['-I' phtreads_ipath], ['-I' glut_ipath], ... % include dependency
        ['-L' libfreenect_lpath], '-lfreenect', ['-L' glut_lpath], '-lglut64', ['-L' phtreads_lpath], '-lpthreadVC2_x64', ['-L' libusb_lpath], '-lusb', ... % library dependency
        'kinect_mex.cc', '-v');
    
    %     mex('-largeArrayDims', ['-I' libfreenect_ipath], ['-I' phtreads_ipath], ['-I' uni_lpath], ['-I' glut_ipath], ... % include dependency
    %         ['-L' libfreenect_lpath], '-lfreenect', ['-L' glut_lpath], '-lglut64', ['-L' phtreads_lpath], '-lpthreadVC2_x64', ... % library dependency
    %         'test.cpp', '-v');
    
    
elseif ismac % mac
    
    mex ...
    
else % linux 
    
    mex -I/usr/include /home/wei/libfreenect/build/lib/libfreenect.so kinect_mex.cc % Linux 64-bit
    
end

if exist(mex_name, 'file') ~= 3 % compile failed
    ret = 0;
end

end

