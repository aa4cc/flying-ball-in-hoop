function ceq = collocation_nonlncon_eq( z, x0, N, f )
ceq = zeros(4, N);

Ts = z(end);
z = z(1:end-1);

z = reshape(z, 5, N)';
u = z(:,5);
u = [u; u(end)];
z = z(:,1:4);
z = [x0(:)'; z];


for k = 2:size(z,1)
    x1 = z(k-1,:)';
    x2 = z(k,:)';
    u1 = u(k-1);
    u2 = u(k);

    f1 = f(x1, u1);
    f2 = f(x2, u2);
    xc = (x1+x2)/2 + Ts*(f1-f2)/8;
    fc = f(xc, (u1+u2)/2);
    Dxc = -3*(x1-x2)/2/Ts - (f1+f2)/4;

    ceq(:,k-1) = fc - Dxc;
end


ceq = ceq(:);

end