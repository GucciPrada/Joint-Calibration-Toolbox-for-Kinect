function [ p ] = find_system_path( f )
p = '';
path = getenv('path');
dirs = regexp(path,psathsep,'split');

for iDirs = 1:numel(dirs)
    tp = fullfile(dirs{iDirs},f);
    if exist(p,'file')
        p = tp;
        break
    end
end

end

