% --------------------------------------------------------
% Rotation of the 3D Plot
    function [x, y, z] = Rotate3D(x, y, z, angle, R)
        angle  = angle +0.9;
        Rx = [1 0 0; 0 cosd(angle) -sind(angle); 0 sind(angle) cosd(angle)];
        Ry = [cosd(angle) 0 sind(angle); 0 1 0; -sind(angle) 0 cosd(angle)];
        Rz = [cosd(angle) -sind(angle) 0; sind(angle) cosd(angle) 0; 0 0 1];
        
        length = size(z);
        xDim = single([]);           % Empty Arrays for XYZ dimensions
        yDim = single([]);
        zDim = single([]);
        
        if (R == 1)
            for a = 1:length(2)
               xDim(a) = x(a)*Ry(1,1) + y(a)*Ry(1,2)+ z(a)*Ry(1,3);
               yDim(a) = x(a)*Ry(2,1) + y(a)*Ry(2,2)+ z(a)*Ry(2,3);
               zDim(a) = x(a)*Ry(3,1) + y(a)*Ry(3,2)+ z(a)*Ry(3,3)+0.2;
            end
        else
            for a = 1:length(2)
               xDim(a) = x(a)*Rx(1,1) + y(a)*Rx(1,2)+ z(a)*Rx(1,3);
               yDim(a) = x(a)*Rx(2,1) + y(a)*Rx(2,2)+ z(a)*Rx(2,3);
               zDim(a) = x(a)*Rx(3,1) + y(a)*Rx(3,2)+ z(a)*Rx(3,3);
            end
        end
        
        z = zDim;
        y = yDim;
        x = xDim;
    end