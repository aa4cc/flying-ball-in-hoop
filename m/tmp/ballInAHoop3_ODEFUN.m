function dx = ballInAHoop3_ODEFUN(x, u, prms)
% x(1) - Dtheta
% x(2) - psi
% x(3) - Dpsi
Dth = x(1);
psi = x(2);
Dpsi = x(3);

a_bar = prms.out.a_bar;
b_bar = prms.out.b_bar;
c_bar = prms.out.c_bar;
d_bar = prms.out.d_bar;
e_bar = prms.out.e_bar;

ath_bar = prms.ath_bar;
bth_bar = prms.bth_bar;

dx = [  ath_bar*Dth + bth_bar*u;
        Dpsi;
        1 / a_bar * (-b_bar*Dpsi - c_bar*sin(psi) + (-d_bar + e_bar*ath_bar)*Dth + e_bar*bth_bar*u) ];
end