function [K, S] = downpos_K(Q, R, prms)
    [A, B] = ballInAHoop3n_ODEFUN_linMatrices(zeros(4,1), 0, prms);

    C = [0 1 0];
    D = 0;

    sys = ss(A,B,C,D);

    sys_d = c2d(sys, prms.Ts, 'zoh');
    [K, S] = lqr(sys_d, Q, R, zeros(3,1));
end