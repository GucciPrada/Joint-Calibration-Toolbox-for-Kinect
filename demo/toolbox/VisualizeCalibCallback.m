function VisualizeCalibCallback( src , event, output_basepath, h)

global cnt

% keyboard strokes
switch lower(event.Character)
    case 'x'
        disp('exit command detected...');
    case 'd'
        disp('switching...');
    case 32 % space
        % disp('space!');
        fout_name = [output_basepath 'test_' gen_frame_number(cnt) '.jpg'];
        export_fig(fout_name, '-jpg', h);
        
        fprintf('recording data to %s\n', fout_name);
        
        cnt = cnt + 1;
    otherwise
        
end

set(h, 'UserData', event.Character);


end

