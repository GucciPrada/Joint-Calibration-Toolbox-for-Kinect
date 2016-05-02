function mouse_callback(src , evt)

buttonclick = get(gcf,'SelectionType');

switch lower(buttonclick)
    case 'x'
        disp('exit command detected...');
    case 32 % space
%         disp('space!');
    otherwise
        % do nothing
end

end

