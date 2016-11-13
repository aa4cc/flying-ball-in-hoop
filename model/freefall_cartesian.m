function dx = freefall_cartesian( t, z )

g = 9.81;
% x = [x, Dx, y, Dy]
x = z(1);
Dx = z(2);
y = z(3);
Dy = z(4);

dx = zeros(4,1);

dx(1) = Dx; 
dx(2) = g;
dx(3) = Dy; 
dx(4) = 0;

end

