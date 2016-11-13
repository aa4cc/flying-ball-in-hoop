r0 = 1;
psi0 = 3/4*pi;
Dr0 = 0.1;
Dpsi0 = 0.025;

x0 = r0*cos(psi0);
y0 = r0*sin(psi0);
Dx0 = cos(psi0)*Dr0 - sin(psi0)*r0*Dpsi0;
Dy0 = sin(psi0)*Dr0 + cos(psi0)*r0*Dpsi0;
 

options = odeset('RelTol',1e-8,'AbsTol',1e-10);
% options = odeset();
[t,y]=ode45(@freefall_polar,[0 10],[r0;Dr0;psi0;Dpsi0], options);
[t2,y2]=ode45(@freefall_cartesian,[0 10],[x0;Dx0;y0;Dy0], options);

r = y(:,1);
psi = y(:,3);

x = r.*cos(psi);
y = r.*sin(psi);

plot(y, -x, y2(:,3), -y2(:,1), '--')