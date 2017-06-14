function dSRQ = dre_odeSRQ(t, SRQ, Atf, Btf, Ctf, t_star, x_star, l_star, u_star)
    n = 3;
    S = reshape(SRQ(1:n*n), n, n);
    R = reshape(SRQ(n*n+1:2*n*n), n, n);
    Q = reshape(SRQ(2*n*n+1:3*n*n), n, n);
    
    x = zeros(n,1);
    l = zeros(n,1);
    for i=1:n
        x(i) = interp1(t_star, x_star(:,i), t);
        l(i) = interp1(t_star, l_star(:,i), t);
    end
    u = interp1(t_star, u_star, t);
    
    A = Atf(x, l, u);
    B = Btf(x, l, u);
    C = Ctf(x, l, u);
    
    dS = -S*A - A'*S + S*B*S - C;
    dS = dS(:);
    
    dR = -(A'-S*B)*R;
    dR = dR(:);
    
    dQ = R'*B*R;
    dQ = dQ(:);

    dSRQ = [dS;dR;dQ];
end