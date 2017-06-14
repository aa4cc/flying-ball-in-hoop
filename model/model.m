clear all
%% Outer hoop
% Define symbolic variables
syms th(t) psi(t) tau(t);
syms Ro Rb Ro mb Ib bb g Ih bh

% Calculate derivatives and define kinematic constraints
Dpsi(t) = diff(psi(t), t);
Dth(t) = diff(th(t), t);
DDpsi(t) = diff(psi(t), t, t);
DDth(t) = diff(th(t), t, t);

phi(t) = (th(t)-psi(t))*Ro/Rb;
Dphi(t) = diff(phi(t), t);

v(t) = -(Ro-Rb)*Dpsi(t);

%% Define energies and the Lagrangian
% Kinetic energy
T = simplify(1/2*(mb*v^2 + Ib*(Dphi(t)+Dth(t))^2 + Ih*Dth^2));

% Potential energy
V = -mb*g*(Ro-Rb)*cos(psi(t));

% Friction (system content)
J = 1/2*bb*Dphi(t)^2 + 1/2*bh*Dth(t)^2;

% Define the lagragian
L = T - V;

% Convert the time dependent symbolic functions to independent symbolic
% variables. This is needed for the partial differentiation.
Ls = subs(L, {Dpsi, Dth, psi, th}, {'Dpsi', 'Dth', 'psi', 'th'});
Js = subs(J, {Dpsi, Dth, psi, th}, {'Dpsi', 'Dth', 'psi', 'th'});

%% Calculate the partial derivatives
% - Partial derivatives of the lagrangian
% d(L)/dDTh(t)
dLdDth = diff(Ls, 'Dth');
% d(L)/dTh(t)
dLdth = diff(Ls, 'th');
% d(L)/dDPsi(t)
dLdDpsi = diff(Ls, 'Dpsi');
% d(L)/dPsi(t)
dLdpsi = diff(Ls, 'psi');

% - Partial derivatives of the system content
% d(J)/dDTh(t)
dJdDth = diff(Js, 'Dth');
% d(J)/dDPsi(t)
dJdDpsi = diff(Js, 'Dpsi');

% convert back to time dependent symbolic functions. Need for time
% derivatives
dLdDth = subs(dLdDth, {'Dpsi', 'Dth', 'psi', 'th'}, {Dpsi, Dth, psi, th});
dLdth = subs(dLdth, {'Dpsi', 'Dth', 'psi', 'th'}, {Dpsi, Dth, psi, th});
dLdDpsi = subs(dLdDpsi, {'Dpsi', 'Dth', 'psi', 'th'}, {Dpsi, Dth, psi, th});
dLdpsi = subs(dLdpsi, {'Dpsi', 'Dth', 'psi', 'th'}, {Dpsi, Dth, psi, th});

dJdDpsi = subs(dJdDpsi, {'Dpsi', 'Dth', 'psi', 'th'}, {Dpsi, Dth, psi, th});
dJdDth = subs(dJdDth, {'Dpsi', 'Dth', 'psi', 'th'}, {Dpsi, Dth, psi, th});

%% Calculate the total time derivatives
ddLdDthdt = diff(dLdDth, 't');
ddLdDpsidt = diff(dLdDpsi, 't');

%% Compute the resulting equations
eqTh = ddLdDthdt - dLdth + dJdDth - tau;
eqPsi = ddLdDpsidt - dLdpsi + dJdDpsi;

%%
pretty(collect(eqTh, [diff(Dpsi,t), diff(Dth,t), Dpsi, Dth, psi, th]))
pretty(collect(eqPsi, [diff(Dpsi,t), diff(Dth,t), Dpsi, Dth, psi, th]))
%%

M = [Ih+Ib*(Ro/Rb+1)^2,             -(Ib*Ro*(Ro/Rb + 1))/Rb
     (-(Ib*Ro*(Ro/Rb + 1))/Rb),     (mb*(Rb - Ro)^2 + (Ib*Ro^2)/Rb^2)];
 
Q = [(bh + (Ro^2*bb)/Rb^2),     (-(Ro^2*bb)/Rb^2)
     (-(Ro^2*bb)/Rb^2),         ((Ro^2*bb)/Rb^2)];
 
C = [0;
     (-g*mb*(Rb - Ro))];

B = [1;0];

% M*[DDth; DDpsi] + Q*[Dth; Dpsi] + C*sin(psi) - B*tau

% M\(-Q*[Dth; Dpsi] -C*sin(psi) + B*tau)

A1 = -M\Q;
A2 = -M\C;
A3 = M\B;

ath1 = A1(1,1);
ath2 = A2(1);
ath3 = A1(1,2);
bth  = A3(1); 

apsi1 = A1(2,1);
apsi2 = A2(2);
apsi3 = A1(2,2);
bpsi  = A3(2);
%%
ath1_f = matlabFunction(ath1, 'Vars', {'Rb', 'Ro', 'mb', 'g', 'Ib', 'Ih', 'bb', 'bh'});
ath2_f = matlabFunction(ath2, 'Vars', {'Rb', 'Ro', 'mb', 'g', 'Ib', 'Ih', 'bb', 'bh'});
ath3_f = matlabFunction(ath3, 'Vars', {'Rb', 'Ro', 'mb', 'g', 'Ib', 'Ih', 'bb', 'bh'});
bth_f  = matlabFunction(bth,  'Vars', {'Rb', 'Ro', 'mb', 'g', 'Ib', 'Ih', 'bb', 'bh'});
apsi1_f = matlabFunction(apsi1, 'Vars', {'Rb', 'Ro', 'mb', 'g', 'Ib', 'Ih', 'bb', 'bh'});
apsi2_f = matlabFunction(apsi2, 'Vars', {'Rb', 'Ro', 'mb', 'g', 'Ib', 'Ih', 'bb', 'bh'});
apsi3_f = matlabFunction(apsi3, 'Vars', {'Rb', 'Ro', 'mb', 'g', 'Ib', 'Ih', 'bb', 'bh'});
bpsi_f  = matlabFunction(bpsi,  'Vars', {'Rb', 'Ro', 'mb', 'g', 'Ib', 'Ih', 'bb', 'bh'});

%%
addpath('../m')
params_init;

ath1_ev		= 	prmsf.ath1_f(prms.Rb,	prms.Ro, prms.m, prms.g,	prms.Ib, prms.Ih, bb, bh)
ath2_ev		= 	prmsf.ath2_f(prms.Rb,	prms.Ro, prms.m, prms.g,	prms.Ib, prms.Ih, bb, bh)
ath3_ev		= 	prmsf.ath3_f(prms.Rb,	prms.Ro, prms.m, prms.g,	prms.Ib, prms.Ih, bb, bh)
bth_ev		= 	prmsf.bth_f(prms.Rb,	prms.Ro, prms.m, prms.g,	prms.Ib, prms.Ih, bb, bh)
apsi1_ev	= 	prmsf.apsi1_f(prms.Rb,	prms.Ro, prms.m, prms.g,	prms.Ib, prms.Ih, bb, bh)
apsi2_ev	= 	prmsf.apsi2_f(prms.Rb,	prms.Ro, prms.m, prms.g,	prms.Ib, prms.Ih, bb, bh)
apsi3_ev	= 	prmsf.apsi3_f(prms.Rb,	prms.Ro, prms.m, prms.g,	prms.Ib, prms.Ih, bb, bh)
bpsi_ev		= 	prmsf.bpsi_f(prms.Rb,	prms.Ro, prms.m, prms.g,	prms.Ib, prms.Ih, bb, bh)


return
%%
Ih = 0.0015;
M = [Ih + prms.Ib*(prms.Ro/prms.Rb+1)^2,                    -(prms.Ib*prms.Ro*(prms.Ro/prms.Rb + 1))/prms.Rb
     (-(prms.Ib*prms.Ro*(prms.Ro/prms.Rb + 1))/prms.Rb),     (prms.m*(prms.Rb - prms.Ro)^2 + (prms.Ib*prms.Ro^2)/prms.Rb^2)];
 
Q = [(bh + (prms.Ro^2*bb)/prms.Rb^2),     (-(prms.Ro^2*bb)/prms.Rb^2)
     (-(prms.Ro^2*bb)/prms.Rb^2),         ((prms.Ro^2*bb)/prms.Rb^2)];
 
C = [0;
     (-prms.g*prms.m*(prms.Rb - prms.Ro))];

B = [1;0];


vpa(simplify(M\(-Q*[Dth; Dpsi] -C*sin(psi) + B*tau)), 2)
%%
% M = sym('M', [2 2], 'real');
Q = sym('Q', [2 2], 'real');
C = sym('C', [2, 1], 'real');
C(1) = 0;
B = sym('B', [2, 1], 'real');
B(2) = 0;

M\(-Q*[Dth; Dpsi] -C*sin(psi) + B*tau)

%% Finalni odvozeni rovnic
eq1 = ddTdDthdt - dTdth + dUdth + dJdDth + tau(t);
eq2 = ddTdDpsidt - dTdpsi + dVdpsi + dJdDpsi;

eqf1 = subs(eq1, {DDth, DDpsi, Dth, Dpsi, th, psi, tau}, {'ddth', 'ddpsi', 'dth', 'dpsi', 'th', 'psi', 'tau'});
eqf2 = subs(eq2, {DDth, DDpsi, Dth, Dpsi, th, psi, tau}, {'ddth', 'ddpsi', 'dth', 'dpsi', 'th', 'psi', 'tau'});

res = solve(eqf1==0, eqf2==0, 'ddth', 'ddpsi');

ddth = subs(res.ddth, {'ddth', 'ddpsi', 'dth', 'dpsi', 'th', 'psi', 'tau'}, {DDth, DDpsi, Dth, Dpsi, th, psi, tau});
ddpsi = subs(res.ddpsi, {'ddth', 'ddpsi', 'dth', 'dpsi', 'th', 'psi', 'tau'}, {DDth, DDpsi, Dth, Dpsi, th, psi, tau});

% collect(res.ddth, ['dth', 'dpsi', 'psi', 'th', 'tau'])
% eqf1 = subs(res.dda, {'da', 'db', 'dc', 'aa', 'bb', 'cc', 'M'}, {'y(2)', 'y(4)', 'y(6)', 'y(1)', 'y(3)', 'y(5)', 'k*128/14*y(7)'})
% eqf2 = subs(res.ddb, {'da', 'db', 'dc', 'aa', 'bb', 'cc', 'M'}, {'y(2)', 'y(4)', 'y(6)', 'y(1)', 'y(3)', 'y(5)', 'k*128/14*y(7)'})
% eqf3 = subs(res.ddc, {'da', 'db', 'dc', 'aa', 'bb', 'cc', 'M'}, {'y(2)', 'y(4)', 'y(6)', 'y(1)', 'y(3)', 'y(5)', 'k*128/14*y(7)'})



%% Inner hoop
syms th(t) psi(t);
syms Ro Rb Ri mb Ib bb g

phi(t) = (th(t)-psi(t))*Ri/Rb;

Dphi(t) = diff(phi(t), t);
Dpsi(t) = diff(psi(t), t);
Dth(t) = diff(th(t), t);

v(t) = (Ri+Rb)*Dpsi(t);

% Kinetic energy
T = simplify(1/2*(mb*v^2 + Ib*(Dphi(t)-Dth(t))^2));

% Potential energy
V = -mb*g*(Ri+Rb)*cos(psi(t));

% Friction
J = 1/2*bb*Dphi(t)^2;

% Convert the time dependent symbolic functions to independent symbolic
% variables. This is needed for the partial differentiation
Ts = subs(T, {Dpsi, Dth, psi, th}, {'Dpsi', 'Dth', 'psi', 'th'});
Vs = subs(V, {Dpsi, Dth, psi, th}, {'Dpsi', 'Dth', 'psi', 'th'});
Js = subs(J, {Dpsi, Dth, psi, th}, {'Dpsi', 'Dth', 'psi', 'th'});

% d(T)/dDPsi(t)
dTdDpsi = diff(Ts, 'Dpsi');

% d(T)/dPsi(t)
dTdpsi = diff(Ts, 'psi');

% d(U)/dPsi(t)
dVdpsi = diff(Vs, 'psi');

% d(J)/dDPsi(t)
dJdDpsi = diff(Js, 'Dpsi');

% convert back to time dependent symbolic functions
dTdDpsi = subs(dTdDpsi, {'Dpsi', 'Dth', 'psi', 'th'}, {Dpsi, Dth, psi, th});
dTdpsi = subs(dTdpsi, {'Dpsi', 'Dth', 'psi', 'th'}, {Dpsi, Dth, psi, th});
dVdpsi = subs(dVdpsi, {'Dpsi', 'Dth', 'psi', 'th'}, {Dpsi, Dth, psi, th});
dJdDpsi = subs(dJdDpsi, {'Dpsi', 'Dth', 'psi', 'th'}, {Dpsi, Dth, psi, th});

% Calculate the total derivative d(d(T)/dDPsi(t))/dt
ddTdDpsidt = diff(dTdDpsi, 't');

pretty(collect(ddTdDpsidt - dTdpsi + dVdpsi + dJdDpsi, [diff(Dpsi,t), diff(Dth,t), Dpsi, Dth, psi, th]))

%
collect(ddTdDpsidt - dTdpsi + dVdpsi + dJdDpsi, [diff(Dpsi,t), Dpsi, sin(psi), Dth, diff(Dth,t)])

%% Free-fall
syms r(t) psi(t);
syms g

x = r(t)*cos(psi(t));
y = r(t)*sin(psi(t));

DDx = simplify(diff(x, t, t));
DDy = simplify(diff(y, t, t));

DDx = subs(DDx, {diff(r, t, t), diff(r, t), r, diff(psi, t, t), diff(psi, t), psi}, {'DDr', 'Dr', 'r', 'DDpsi', 'Dpsi', 'psi'});
DDy = subs(DDy, {diff(r, t, t), diff(r, t), r, diff(psi, t, t), diff(psi, t), psi}, {'DDr', 'Dr', 'r', 'DDpsi', 'Dpsi', 'psi'});

res = solve(DDx==g, DDy==0, 'DDr', 'DDpsi');

DDr = simplify(res.DDr)
DDpsi = simplify(res.DDpsi)