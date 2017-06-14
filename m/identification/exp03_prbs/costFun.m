function cost = costFun(z, y, u, t, x0)

[t_optim, y_optim] = ode45(@(tt, x) hoopODE(tt, x, u, t, z), t, x0);

y_optim = y_optim(:, [1 3]);

cost = norm(y(:) - y_optim(:));

end

function dx = hoopODE(tt, x, u, t, z)
Dth = x(2,:);
psi = x(3,:);
Dpsi = x(4,:);

a22 = z(1);
a23 = z(2);
a24 = z(3);
b2 = z(4);
a42 = z(5);
a43 = z(6);
a44 = z(7);
b4 = z(8);

ut = interp1(t, u, tt, 'previous');

dx = [  Dth;
        a22*Dth + a23*psi + a24*Dpsi + b2*ut;
        Dpsi;
        a42*Dth + a43*sin(psi) + a44*Dpsi + b4*ut];
end