function [ newdata ] = remap_disparity( data, curval )
cls = class(data);

switch cls
    case 'uint16'
        nan_value = 0;
        % map from set {0,1,...,2047} to set {0,1,...,maxval}
        % maxval = 2^n - 1
        n = log2(curval+1);
        newdata = bitshift(data,16-n);
        
        nan_ind = (newdata == nan_value); 
        if ~isempty(nan_ind) % change nan value to highest value for display purpose
            newdata(nan_ind) = 2^16-1;
        end
    otherwise
        newdata = data; % do nothing
end

end

