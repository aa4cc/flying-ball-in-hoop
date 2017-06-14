function cneq = collocation_nonlncon_neq( z, x0, N, f, T, prms)

z = reshape(z(1:end-1), 5, N)';
x = z(:,1:4);

psi = x(1:(N-1),3);
Dpsi = x(1:(N-1),4);

cneq = -prms.g*cos(psi)-(prms.Ro-prms.Rb).*Dpsi.^2;

end