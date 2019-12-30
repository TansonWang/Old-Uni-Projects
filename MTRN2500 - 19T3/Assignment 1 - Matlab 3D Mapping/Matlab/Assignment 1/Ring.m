% -----------------------------------------
% Filtering Cylindrical Ring
    function [xIn, yIn, zIn, xOut, yOut, zOut] = Ring(x, y, z, Inner, Outer)
        xRing = single([]);         % Empty Arrays for XYZ dimensions
        yRing = single([]);
        zRing = single([]);
        
        xNot = single([]);          % Empty Arrays for XYZ dimensions
        yNot = single([]);
        zNot = single([]);
        
        length = size(z);
        n = 1;
        m = 1;
        for c = 1:length(2)
           radius = y(c)^2 + x(c)^2;
           if (z(c) > 0.15 && radius > Inner^2 && radius < Outer^2)
               zRing(n) = z(c);
               yRing(n) = y(c);
               xRing(n) = x(c);
               n = n+1;
           else
               zNot(m) = z(c);
               yNot(m) = y(c);
               xNot(m) = x(c);
               m = m+1;
           end
        end
        xIn = xRing;
        yIn = yRing;
        zIn = zRing;
        xOut = xNot;
        yOut = yNot;
        zOut = zNot;
    end
    