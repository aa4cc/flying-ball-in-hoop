function dx = dre_ode( t, x, psi_star, t_star, Q, R, prms)

a =  prms.out.a_bar;
b =  prms.out.b_bar;
c =  prms.out.c_bar;
d =  prms.out.d_bar;
e =  prms.out.e_bar;

S = reshape(x, 3, 3);

psi = interp1(t_star, psi_star, t);

A = [0 0 0; 0 0 1; -d/a -c/a*cos(psi) -b/a]; % system matrix of the linearized continuous model
B = [1;0;e/a];

dS = Q - S*B/R*B'*S + S*A + A'*S;

dx = dS(:);

end

