function cost = costFun(x, t, th, th0)

k1 = x(1);
k2 = x(2);

[t_optim, y_optim] = ode45(@(t,x) [x(2); k2*sin(x(1)) + k1*x(2)], [t(1); t(end)], [th0; 0]);

y = interp1(t_optim, y_optim(:,1), t);

cost = norm(y - th);


end