clear all

addpath('simul')
addpath('../..')
params_init;

%%
syms Dth psi Dpsi DDth_in

Dth_dot = DDth_in;
psi_dot = Dpsi;
Dpsi_dot = 1 / prms.in.a_bar * (-prms.in.b_bar*Dpsi ...
    - prms.in.c_bar*sin(psi) - prms.in.d_bar*Dth + prms.in.e_bar*DDth_in);

f = [Dth_dot;
     psi_dot;
     Dpsi_dot];

xp = [0;pi;0];
up = 0; 

A = jacobian(f, [Dth, psi, Dpsi]);
A = double(subs(A, {'Dth', 'psi', 'Dpsi'}, {xp(1), xp(2), xp(3)}));

B = diff(f, DDth_in);
B = double(subs(B, DDth_in, up));

C = [0 1 0];
D = 0;

sys = ss(A,B,C,D);

sys_d = c2d(sys, 1/50, 'zoh');
Ad = sys_d.A;
Bd = sys_d.B;
Cd = sys_d.C;
Dd = sys_d.D;
%%
% Q = diag([0e0 1e5 1e5]);
% R = 1e0;
Q = 1e2*diag([.1, 5, .5]);
R = 0.5e-1;

K = single(lqr(sys, Q, R, zeros(3,1)));

th0 = 0;
Dth0 = 0;
psi0 = pi;
Dpsi0 = 0;

P0 = single(eye(2));
x0 = single([psi0; Dpsi0]);

