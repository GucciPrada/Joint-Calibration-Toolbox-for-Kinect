function [ num_str ] = gen_frame_number( num )

% elegant solution
format = sprintf('%%.4d', num);
num_str = sprintf(format, num);

% if num < 10
%     num_str = sprintf('000%d', num);
% elseif num >= 10 && num < 100
%     num_str = sprintf('00%d', num);
% elseif num >= 100 && num < 1000
%     num_str = sprintf('0%d', num);
% else
%     num_str = sprintf('%d', num);
%     warning('frame number is larger than 1000');
% end


end

