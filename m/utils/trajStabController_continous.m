function [ K ] = trajStabController_continous( t_star, x_star, T, Q, Qf, R, prms )

a =  prms.out.a_bar;
b =  prms.out.b_bar;
c =  prms.out.c_bar;
d =  prms.out.d_bar;
e =  prms.out.e_bar;
B = [1;0;e/a];

psi_star = x_star(:,3);

%% Solve the associated DRE

Sf = Qf;
[t, S] = ode45(@(t, s) dre_ode( -t, s, psi_star, t_star, Q, R, prms), [-t_star(end) -t_star(1)], Sf(:) );
S = S(end:-1:1,:);
t = -t(end:-1:1);

Kc = zeros(size(S,1), 3);
for i=1:size(S,1)
    St = reshape( squeeze(S(i,:,:)), 3, 3 );
    Kc(i,:) = R\B'*St;
end


K = zeros(numel(t_star), 1, 3);
for i = 1:size(K,1)
    k1 = interp1(t, Kc(:,1), t_star(i));
    k2 = interp1(t, Kc(:,2), t_star(i));
    k3 = interp1(t, Kc(:,3), t_star(i));
    
    K(i,:,:) = -[k1 k2 k3];
end

end