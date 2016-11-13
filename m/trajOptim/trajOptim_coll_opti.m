function [ t_star, u_star, x_star, Ts ] = trajOptim_coll_opti( xf_des, N, prms, varargin)
% function [ t_star, u_star, x_star ] = trajOptim_coll_opti( x0, xf_des, prms.Ts, Tf, prms, umax, h_costFun, xf_eq, nlcon_neq, zi)
% Number of samples
p = inputParser;
default_costFun = @costFun;
default_umax = Inf;
default_x0 = [0;0;0;0];
default_xf_hardcon = {};
default_opt_initVal = [zeros(5*N, 1); 1];
default_grad = [];
default_nlcon_neq = [];
default_nlcon_neq_jac = [];
default_nlcon_eq = [];
default_nlcon_eq_jac = [];
default_Tf_lim = [0.5 5];
default_lcon_neq.Aneq = [];
default_lcon_neq.bneq = [];

addParameter(p, 'costFun', default_costFun);
addParameter(p, 'umax', default_umax, @isnumeric);
addParameter(p, 'x0', default_x0);
addParameter(p, 'xf_hardcon', default_xf_hardcon);
addParameter(p, 'opt_initVal', default_opt_initVal);
addParameter(p, 'grad', default_grad);
addParameter(p, 'nlcon_neq', default_nlcon_neq);
addParameter(p, 'nlcon_neq_jac', default_nlcon_neq_jac);
addParameter(p, 'nlcon_eq', default_nlcon_eq);
addParameter(p, 'nlcon_eq_jac', default_nlcon_eq_jac);
addParameter(p, 'Tf_lim', default_Tf_lim);
addParameter(p, 'lcon_neq', default_lcon_neq);
parse(p,varargin{:});


% Objective function
fun = @(x) p.Results.costFun( x, xf_des, N );
optiproblem = optiprob('fun', fun, 'x0',p.Results.opt_initVal);

if ~isempty(p.Results.xf_hardcon)
    Aeq = [];
    beq = [];
    
    for i = 1:numel(p.Results.xf_hardcon)
        n = p.Results.xf_hardcon{i}.n;
        k = p.Results.xf_hardcon{i}.k;
        x = p.Results.xf_hardcon{i}.x;
        
        if (k-1) + numel(x) > 4
            error('An error in the linear equality constraint specification.');
        end
        
        Aeqi = zeros(numel(x), 5*N + 1);
        Aeqi(:, (n-1)*5 + (k-1) + (1:numel(x)) ) = eye(numel(x));
        
        Aeq = [Aeq; Aeqi];
        beq = [beq; x];
    end
    
    optiproblem = optiprob(optiproblem, 'eq', Aeq, beq);
end

f = @(x, u) ballInAHoopODEFUN(x, u, prms);

if p.Results.umax ~= Inf
    ul = eye(5*N+1); ul = ul(5:5:end,:);
    Aneq_u = [ul;-ul];
    bneq_u = p.Results.umax*ones(size(Aneq_u,1),1);        
else
    Aneq_u = [];
    bneq_u = [];
end
Aneq_Ts = [zeros(2, 5*N) [1; -1] ];
bneq_Ts = [p.Results.Tf_lim(2)/N; -p.Results.Tf_lim(1)/N];

Aneq = [Aneq_Ts; Aneq_u; p.Results.lcon_neq.Aneq];
bneq = [bneq_Ts; bneq_u; p.Results.lcon_neq.bneq];
optiproblem = optiprob(optiproblem, 'ineq', Aneq, bneq);

%%% Constraints
% Nonlinear - equality
if ~isempty(p.Results.nlcon_eq)
    nlcon_eq = @(z) collocation_nonlncon_eq( z, p.Results.x0, N, f );
    nlncon_eq_n = numel(nlcon_eq(p.Results.opt_initVal));
    nlrhs_eq = zeros(nlncon_eq_n,1);
    nle_eq = zeros(nlncon_eq_n,1);

    if ~isempty(p.Results.nlcon_eq_jac)
        % Jacobians
        jac1 = collocation_nonlncon_eq_J( p.Results.x0, N, @(x, u) ballInAHoopODEFUN_forGrad(x, u, prms), prms );
    else
        jac1 = @(z) [];
    end
else
    nlcon_eq = @(z) [];
    nlrhs_eq = [];
    nle_eq = [];    
    jac1 = @(z) [];
end

% Nonlinear - inequality
if ~isempty(p.Results.nlcon_neq)
    nlcon_neq = @(z) p.Results.nlcon_neq( z, p.Results.x0, N, f, prms.Ts, prms);
    
    nlncon_neq_n = numel(nlcon_neq(p.Results.opt_initVal));
    nlrhs_neq = zeros(nlncon_neq_n,1);
    nle_neq = -1*ones(nlncon_neq_n,1);
    
    if ~isempty(p.Results.nlcon_neq_jac)
        % Jacobians
        jac2 = collocation_nonlncon_neq_J( N, prms);    
    else
        jac2 = @(z) [];
    end
else
    nlcon_neq = @(z) [];
    nlrhs_neq = [];
    nle_neq = [];
    jac2 = @(z) [];
end

nlcon = @(z) [nlcon_eq(z); nlcon_neq(z)];
nlrhs = [nlrhs_eq; nlrhs_neq];
nle = [nle_eq; nle_neq];
jac = @(z) [jac1(z); jac2(z)];

if ~isempty(nle)
    optiproblem = optiprob(optiproblem, 'nlmix',nlcon,nlrhs,nle);
end

if ~isempty(jac(p.Results.opt_initVal))
    optiproblem = optiprob(optiproblem, 'jac', jac);
end

if ~isempty(p.Results.grad)
    grad = @(x) p.Results.grad( x, xf_des, N );
    optiproblem = optiprob(optiproblem, 'grad', grad);
end

% Options
opts = optiset('solver', 'ipopt', ...
    'display', 'iter', ...
    'maxiter', 1e4, ...
    'maxfeval', 5e4, ...
    'maxtime', 2e3);

Opt = opti(optiproblem, opts);

% Build OPTI Object
% Opt = opti('fun',fun,'nlmix',nlcon,nlrhs,nle,'ineq',A,b,'eq',Aeq,beq,'x0',p.Results.opt_initVal,'options',opts, 'grad', grad, 'jac', jac);
% Opt = opti('fun',fun,'nlmix',nlcon,nlrhs,nle,'ineq',A,b,'eq',Aeq,beq,'x0',p.Results.opt_initVal,'options',opts);

% Solve NLP
z_star = solve(Opt);

%
Ts = z_star(end);
z_tmp = reshape(z_star(1:end-1), 5, N)';

u_star = z_tmp(:, 5);
x_star = z_tmp(:, 1:4);
t_star = 0:Ts:(N-1)*Ts;

end

