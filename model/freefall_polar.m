function dx = freefall_polar( t, x )

g = 9.81;
% x = [r, Dr, psi, Dpsi]
r = x(1);
Dr = x(2);
psi = x(3);
Dpsi = x(4);

dx = zeros(4,1);

dx(1) = Dr; 
dx(2) = r*Dpsi^2 + g*cos(psi);
dx(3) = Dpsi; 
dx(4) = -g/r*sin(psi)-2/r*Dpsi*Dr;

end

