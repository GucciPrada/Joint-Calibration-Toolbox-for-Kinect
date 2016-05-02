function get_wall_images( src_dir, dst_dir, start_ind, end_ind )

if nargin < 1
    src_dir = '../wall/';
    dst_dir = '../wall_format/'; % for debug
    start_ind = 0;
end

file_names = getAllFiles(src_dir);
if nargin < 4
    end_ind = start_ind + length(file_names) - 1;
end

% change name of wall image and then copy it to dst_dir
for i = 1 : length(file_names)
    [~,name,ext] = fileparts(file_names{i});
    
    save_path = [dst_dir gen_frame_number(start_ind) '-d.pgm'];
    
    copyfile(file_names{i}, dst_dir);
    movefile([dst_dir name ext], save_path)
    
    fprintf('wall image ''%d'' copied to %s\n', i, save_path);
    if start_ind >= end_ind
        break;
    end
    start_ind = start_ind + 1;
end

end