function dS = dre_odeQ(t, S, Atf, Btf, Q, t_star, x_star, l_star, u_star)
    n = sqrt(numel(S));
    S = reshape(S, n, n);
    
    x = zeros(n,1);
    l = zeros(n,1);
    for i=1:n
        x(i) = interp1(t_star, x_star(:,i), t);
        l(i) = interp1(t_star, l_star(:,i), t);
    end
    u = interp1(t_star, u_star, t);
    
    A = Atf(x, l, u);
    B = Btf(x, l, u);
    
    dS = -S*A - A'*S + S*B*S - Q;

    dS = dS(:);
end