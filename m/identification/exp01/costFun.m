function cost = costFun(x, t, th, th0)

k1 = x(1);
k2 = x(2);

[t_optim, y_optim] = ode45(@(t,x) [x(2); k2*sin(x(1)) + k1*x(2)], [t(1); t(end)], [th0; 0]);

y = interp1(t_optim, y_optim(:,1), t);

cost = norm(y - th);

end

function dx = diffEq(t, x, z, prms)
% -- On a hoop --
% x(1) - theta
% x(2) - Dtheta
% x(3) - psi
% x(4) - Dpsi

Dth = x(2,:);
psi = x(3,:);
Dpsi = x(4,:);


ath_bar = prms.ath_bar;

dx = [  Dth;
        ath_bar*Dth + z(1)*Dpsi + z(2)*sin(psi);
        Dpsi;
        -z(3)*Dpsi - z(4)*sin(psi) + z(5)*Dth];
    
    
% dx = [  Dth;
%         ath_bar*Dth + z(1)*Dpsi + z(2)*sin(psi);
%         Dpsi;
%         1 / a_bar * (-b_bar*Dpsi - c_bar*sin(psi) + (-d_bar + e_bar*ath_bar)*Dth) ];
    
end