%Series expansion of the lambertw() function.
% This eliminates the dependency on the symbolic toolbox.
% Thanks to Oliver Woodford for the idea and implementation.
function res = lambertw_fast(x)
  persistent series_weights
  if isempty(series_weights)
      n = 10;
      series_weights = (((-(1:n)) .^ (0:n-1)) ./ cumprod(1:n))';
  end
  res = reshape(bsxfun(@power, x(:), 1:numel(series_weights)) * series_weights, size(x));
end