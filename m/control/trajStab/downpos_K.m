function [K, S] = downpos_K(Q, R, prms)
    A = [         0         0         0;
         0         0    1.0000;
    0.4843  -66.5959   -0.4843];

    B = [1.0000;
         0;
    0.4086];

    C = [0 1 0];
    D = 0;

    sys = ss(A,B,C,D);

    sys_d = c2d(sys, prms.Ts, 'zoh');
    Ad = sys_d.A;
    Bd = sys_d.B;
    Cd = sys_d.C;
    Dd = sys_d.D;
    %%
    [K, S] = lqr(sys, Q, R, zeros(3,1));
end