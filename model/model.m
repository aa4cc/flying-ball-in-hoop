clear all
%% Outer hoop
syms th(t) psi(t);
syms Ro Rb Ro mb Ib bb g

phi(t) = (th(t)-psi(t))*Ro/Rb;

Dphi(t) = diff(phi(t), t);
Dpsi(t) = diff(psi(t), t);
Dth(t) = diff(th(t), t);

v(t) = -(Ro-Rb)*Dpsi(t);

% Kinetic energy
T = simplify(1/2*(mb*v^2 + Ib*(Dphi(t)+Dth(t))^2));

% Potential energy
U = -mb*g*(Ro-Rb)*cos(psi(t));

% Friction
J = 1/2*bb*Dphi(t)^2;

% Convert the time dependent symbolic functions to independent symbolic
% variables. This is needed for the partial differentiation
Ts = subs(T, {Dpsi, Dth, psi, th}, {'Dpsi', 'Dth', 'psi', 'th'});
Us = subs(U, {Dpsi, Dth, psi, th}, {'Dpsi', 'Dth', 'psi', 'th'});
Js = subs(J, {Dpsi, Dth, psi, th}, {'Dpsi', 'Dth', 'psi', 'th'});

% d(T)/dDPsi(t)
dTdDpsi = diff(Ts, 'Dpsi');

% d(T)/dPsi(t)
dTdpsi = diff(Ts, 'psi');

% d(U)/dPsi(t)
dUdpsi = diff(Us, 'psi');

% d(J)/dDPsi(t)
dJdDpsi = diff(Js, 'Dpsi');

% convert back to time dependent symbolic functions
dTdDpsi = subs(dTdDpsi, {'Dpsi', 'Dth', 'psi', 'th'}, {Dpsi, Dth, psi, th});
dTdpsi = subs(dTdpsi, {'Dpsi', 'Dth', 'psi', 'th'}, {Dpsi, Dth, psi, th});
dUdpsi = subs(dUdpsi, {'Dpsi', 'Dth', 'psi', 'th'}, {Dpsi, Dth, psi, th});
dJdDpsi = subs(dJdDpsi, {'Dpsi', 'Dth', 'psi', 'th'}, {Dpsi, Dth, psi, th});

% Calculate the total derivative d(d(T)/dDPsi(t))/dt
ddTdDpsidt = diff(dTdDpsi, 't');

pretty(collect(ddTdDpsidt - dTdpsi + dUdpsi + dJdDpsi, [diff(Dpsi,t), diff(Dth,t), Dpsi, Dth, psi, th]))

%
collect(ddTdDpsidt - dTdpsi + dUdpsi + dJdDpsi, [diff(Dpsi,t), Dpsi, sin(psi), Dth, diff(Dth,t)])

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
U = -mb*g*(Ri+Rb)*cos(psi(t));

% Friction
J = 1/2*bb*Dphi(t)^2;

% Convert the time dependent symbolic functions to independent symbolic
% variables. This is needed for the partial differentiation
Ts = subs(T, {Dpsi, Dth, psi, th}, {'Dpsi', 'Dth', 'psi', 'th'});
Us = subs(U, {Dpsi, Dth, psi, th}, {'Dpsi', 'Dth', 'psi', 'th'});
Js = subs(J, {Dpsi, Dth, psi, th}, {'Dpsi', 'Dth', 'psi', 'th'});

% d(T)/dDPsi(t)
dTdDpsi = diff(Ts, 'Dpsi');

% d(T)/dPsi(t)
dTdpsi = diff(Ts, 'psi');

% d(U)/dPsi(t)
dUdpsi = diff(Us, 'psi');

% d(J)/dDPsi(t)
dJdDpsi = diff(Js, 'Dpsi');

% convert back to time dependent symbolic functions
dTdDpsi = subs(dTdDpsi, {'Dpsi', 'Dth', 'psi', 'th'}, {Dpsi, Dth, psi, th});
dTdpsi = subs(dTdpsi, {'Dpsi', 'Dth', 'psi', 'th'}, {Dpsi, Dth, psi, th});
dUdpsi = subs(dUdpsi, {'Dpsi', 'Dth', 'psi', 'th'}, {Dpsi, Dth, psi, th});
dJdDpsi = subs(dJdDpsi, {'Dpsi', 'Dth', 'psi', 'th'}, {Dpsi, Dth, psi, th});

% Calculate the total derivative d(d(T)/dDPsi(t))/dt
ddTdDpsidt = diff(dTdDpsi, 't');

pretty(collect(ddTdDpsidt - dTdpsi + dUdpsi + dJdDpsi, [diff(Dpsi,t), diff(Dth,t), Dpsi, Dth, psi, th]))

%
collect(ddTdDpsidt - dTdpsi + dUdpsi + dJdDpsi, [diff(Dpsi,t), Dpsi, sin(psi), Dth, diff(Dth,t)])

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