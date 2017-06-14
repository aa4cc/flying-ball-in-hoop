function dx = ballInAHoop3K_ODEFUN(t, x, t_star, x_star, u_star, tK, K, prms)

    N = size(K,2);
    K_interp = zeros(1,N);
    x_interp = zeros(N,1);
    for i=1:N
        K_interp(i) = interp1(tK, K(:,i), t);
        x_interp(i) = interp1(t_star, x_star(:,i), t);
    end
    u_interp = interp1(t_star, u_star, t);
    
    du = K_interp*(x-x_interp);
%     du = 0;
    
    dx = ballInAHoop3_ODEFUN(x, u_interp + du, prms);

end