function cost = costFunHoopAndBall2(z, tt, Dth, psi, u, prms)

prmsTmp = prms;
prmsTmp.ath1	= 	z(1);
prmsTmp.ath2	= 	z(2)*10;
% prmsTmp.ath3	= 	z(3);
prmsTmp.bth		= 	600*z(3);
prmsTmp.apsi1	= 	z(4)/10;
% prmsTmp.apsi2	= 	z(5);
prmsTmp.apsi3	= 	z(5);
prmsTmp.bpsi	= 	300*z(6);

[~, y_sim] = ode45(@(t,x) ballInAHoopODEFUN(t, x, prmsTmp, tt, u), tt, [0; 0; psi(1); 0]);

Dth_sim = y_sim(:,2);
psi_sim = y_sim(:,3);

cost = norm((Dth_sim - Dth)/25) + norm((psi_sim - psi)*2);

figure(1)
subplot(211)
plot(tt, Dth, tt, Dth_sim)
subplot(212)
plot(tt, psi, tt, psi_sim)

pause(.1)

end