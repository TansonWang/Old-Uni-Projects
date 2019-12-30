% -----------------------------------------
% Filtering Z High and Low
    function [x, y, z] = FilterZ(x, y, z)
        xHLz = single([]);         % Empty Arrays for XYZ dimensions
        yHLz = single([]);
        zHLz = single([]);
        length = size(z);
        n = 1;
        for c = 1:length(2)
           if (z(c) > -0.05 && z(c) < 1)
               zHLz(n) = z(c);
               yHLz(n) = y(c);
               xHLz(n) = x(c);
               n = n+1;
           end
        end
        x = xHLz;
        y = yHLz;
        z = zHLz;
    end
    