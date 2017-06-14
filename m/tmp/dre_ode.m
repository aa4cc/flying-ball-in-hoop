function dS = dre_ode(t, S, Atf, Btf, Ctf, t_star, x_star, l_star, u_star)
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
    C = Ctf(x, l, u);
    
    dS = -S*A - A'*S + S*B*S - C;

    dS = dS(:);
end