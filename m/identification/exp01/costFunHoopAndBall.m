function cost = costFunHoopAndBall(z, t, th, psi, prms, prmsf)

bh = 1e-6*z(1);
prmsTmp.ath1	= 	prmsf.ath1_f(prms.Rb,	prms.Ro, prms.m, prms.g,	prms.Ib, prms.Ih, prms.bb, bh);
prmsTmp.ath2	= 	prmsf.ath2_f(prms.Rb,	prms.Ro, prms.m, prms.g,	prms.Ib, prms.Ih, prms.bb, bh);
prmsTmp.ath3	= 	prmsf.ath3_f(prms.Rb,	prms.Ro, prms.m, prms.g,	prms.Ib, prms.Ih, prms.bb, bh);
prmsTmp.bth		= 	prmsf.bth_f(prms.Rb,	prms.Ro, prms.m, prms.g,	prms.Ib, prms.Ih, prms.bb, bh);
prmsTmp.apsi1	= 	prmsf.apsi1_f(prms.Rb,	prms.Ro, prms.m, prms.g,	prms.Ib, prms.Ih, prms.bb, bh);
prmsTmp.apsi2	= 	prmsf.apsi2_f(prms.Rb,	prms.Ro, prms.m, prms.g,	prms.Ib, prms.Ih, prms.bb, bh);
prmsTmp.apsi3	= 	prmsf.apsi3_f(prms.Rb,	prms.Ro, prms.m, prms.g,	prms.Ib, prms.Ih, prms.bb, bh);
prmsTmp.bpsi	= 	prmsf.bpsi_f(prms.Rb,	prms.Ro, prms.m, prms.g,	prms.Ib, prms.Ih, prms.bb, bh);

prmsTmp.ath1	= 	z(1);
prmsTmp.ath2	= 	z(4);
prmsTmp.ath3	= 	z(5);
% prmsTmp.bth		= 	prmsf.bth_f(prms.Rb,	prms.Ro, prms.m, prms.g,	prms.Ib, prms.Ih, prms.bb, bh);
prmsTmp.apsi1	= 	z(6);
% prmsTmp.apsi2	= 	prmsf.apsi2_f(prms.Rb,	prms.Ro, prms.m, prms.g,	prms.Ib, prms.Ih, prms.bb, bh);
% prmsTmp.apsi3	= 	prmsf.apsi3_f(prms.Rb,	prms.Ro, prms.m, prms.g,	prms.Ib, prms.Ih, prms.bb, bh);
% prmsTmp.bpsi	= 	prmsf.bpsi_f(prms.Rb,	prms.Ro, prms.m, prms.g,	prms.Ib, prms.Ih, prms.bb, bh);

[~, y_sim] = ode45(@(t,x) ballInAHoopODEFUN(x, 0, prmsTmp), t, [th(1); z(2); psi(1); z(3)]);

th_sim = y_sim(:,1);
psi_sim = y_sim(:,3);

cost = 2*norm(th_sim - th) + norm(psi_sim - psi);

figure(1)
subplot(211)
plot(t, th, t, th_sim)
subplot(212)
plot(t, psi, t, psi_sim)

pause(.1)

end