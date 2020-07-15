% estimate_sharpness - Estimate sharpness using the gradient magnitude.
% sum of all gradient norms / number of pixels give us the sharpness
% metric.

% https://www.mathworks.com/matlabcentral/fileexchange/32397-sharpness-estimation-from-image-gradients
function [sharpness]=estimate_sharpness(G)
[Gx, Gy]=gradient(G);
S=sqrt(Gx.*Gx+Gy.*Gy);
sharpness=sum(sum(S))./(numel(Gx));
end