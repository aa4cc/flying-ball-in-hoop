function dx = dre_ode( t, x, psi_star, t_star, Q, R, prms)

a =  prms.out.a_bar;
b =  prms.out.b_bar;
c =  prms.out.c_bar;
d =  prms.out.d_bar;
e =  prms.out.e_bar;

ath_bar = prms.ath_bar;
bth_bar = prms.bth_bar;

S = reshape(x, 3, 3);

psi = interp1(t_star, psi_star, t);

A = [ath_bar 0 0; 0 0 1; -d/a+e*ath_bar/a -c/a*cos(psi) -b/a]; % system matrix of the linearized continuous model
B = [bth_bar; 0; e*bth_bar/a];

dS = Q - S*B/R*B'*S + S*A + A'*S;

dx = dS(:);

end

