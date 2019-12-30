%---------------------------------------
% Depth to 3D
function [xx, yy, zz] = Depthto3D (RR)
    depthArray = single(RR)*0.001;  % Scale the depth in m from mm
    depthArraySize = size(RR);      % Get the size
    indDepth = find(depthArray>0);  % Index (all > 0 values) the depth
    % Put the indexed positions into the original array to get a vector of
    % all of the > 0 numbers.
    Not0Points = depthArray(indDepth);
    % Turn the index into two linear arrays which contain the row and the
    % column for the position stored in the index vector
    [R, C] = ind2sub(depthArraySize,indDepth);

    % Calculations
    xx = (Not0Points)';
    yy = (Not0Points.*(C-80)*(4/594))';
    zz = (-Not0Points.*(R-60)*(4/592)-0.2)';
end