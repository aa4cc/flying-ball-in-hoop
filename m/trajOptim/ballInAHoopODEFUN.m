function dx = ballInAHoopODEFUN(x, u, prms)
% -- On a hoop --
% x(1) - theta
% x(2) - Dtheta
% x(3) - psi
% x(4) - Dpsi
Dth = x(2);
psi = x(3);
Dpsi = x(4);

a_bar = prms.out.a_bar;
b_bar = prms.out.b_bar;
c_bar = prms.out.c_bar;
d_bar = prms.out.d_bar;
e_bar = prms.out.e_bar;

dx = zeros(4,1);

dx(1) = Dth;
dx(2) = u;
dx(3) = Dpsi;
dx(4) = 1 / a_bar * (-b_bar*Dpsi - c_bar*sin(psi) - d_bar*Dth + e_bar*u);