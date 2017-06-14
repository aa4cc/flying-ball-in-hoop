function ceq = collocation_nonlncon_eq2( z, x0, N, fun )
Ts = z(end);
z = z(1:end-1);

z = reshape(z, 5, N)';
u = z(:,5);
u = [u; u(end)];
x = z(:,1:4);
x = [x0(:)'; x];

f = fun(x',u')';

uc = (u(1:end-1)+u(2:end))/2;

xc = 1/2*( x(1:end-1,:) + x(2:end,:) ) + Ts/8 * (f(1:end-1,:) - f(2:end,:));
dot_xc = -(3/2/Ts)*( x(1:end-1,:) - x(2:end,:) ) - 1/4* (f(1:end-1,:) + f(2:end,:));
fc = fun(xc', uc')';
ceq = fc-dot_xc;

ceq = ceq(:);

end