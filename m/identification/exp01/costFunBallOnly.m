function cost = costFunBallOnly(z, t, psi, prms, prmsf)

bb = 1e-6*z(1);
bh = 0;

apsi2	= 	prmsf.apsi2_f(prms.Rb,	prms.Ro, prms.m, prms.g,	prms.Ib, prms.Ih, bb, bh);
apsi3	= 	prmsf.apsi3_f(prms.Rb,	prms.Ro, prms.m, prms.g,	prms.Ib, prms.Ih, bb, bh);

% [~, y_sim] = ode45(@(t,x) [x(2); apsi2*sin(x(1)) + apsi3*x(2)], t, [psi(1); z(2)]);
[~, y_sim] = ode45(@(t,x) [x(2); z(3)*sin(x(1)) - z(1)*sign(x(2))*(-prms.g*cos(x(1))-(prms.Ro-prms.Rb)*x(2)^2)], t, [psi(1); z(2)]);


psi_sim = y_sim(:,1);

cost = norm(psi_sim - psi);

figure(1)
plot(t, psi, t, psi_sim)

pause(.1)

% k1 = x(1);
% k2 = x(2);

% [t_optim, y_optim] = ode45(@(t,x) [x(2); k2*sin(x(1)) + k1*x(2)], [t(1); t(end)], [th0; 0]);

% y = interp1(t_optim, y_optim(:,1), t);

% cost = norm(y - th);

end