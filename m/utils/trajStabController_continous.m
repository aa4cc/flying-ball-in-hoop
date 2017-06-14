function [ K ] = trajStabController_continous( t_star, x_star, u_star, Q, Qf, R, prms )

% Solve the associated DRE
Sf = Qf;
opt = odeset('AbsTol',1.0e-07,'RelTol',1.0e-07);
[tS,S] = ode45( @(t, S) dreode(t, S, x_star, u_star, t_star, Q, R, prms), [t_star(end), t_star(1)], Sf, opt);
tS = tS(end:-1:1);
S = S(end:-1:1, :);
S = reshape(S, size(S,1), 3, 3);

Kc = zeros(size(S,1), 3);
for i=1:size(S,1)
    [x_interp, u_interp] = interpStatesAndControls(t_star, x_star, u_star, tS(i));
    [~, Bi] = ballInAHoop3n_ODEFUN_linMatrices(x_interp, u_interp, prms);
    
    Kc(i,:) = -R\Bi'*squeeze(S(i,:,:));
end

% Interpolate the feedback gain K
K = zeros(numel(t_star), 1, 3);
for i = 1:size(K,1)
    k1 = interp1(tS, Kc(:,1), t_star(i));
    k2 = interp1(tS, Kc(:,2), t_star(i));
    k3 = interp1(tS, Kc(:,3), t_star(i));
    
    K(i,:,:) = [k1 k2 k3];
end

end

function dS = dreode( t, S, x_star, u_star, t_star, Q, R, prms)
    n = sqrt(numel(S));
    S = reshape(S, n, n);

    [x_interp, u_interp] = interpStatesAndControls(t_star, x_star, u_star, t);
    [A, B] = ballInAHoop3n_ODEFUN_linMatrices(x_interp, u_interp, prms);
    
    dS = -Q + S*B/R*B'*S - S*A - A'*S;

    dS = dS(:);

end

function [x_interp, u_interp] = interpStatesAndControls(t, x, u, tq)
    n = size(x,2);

    x_interp = zeros(n, 1);
    for i=1:n
        x_interp(i) = interp1(t, x(:,i), tq);
    end
    u_interp = interp1(t, u, tq);
end