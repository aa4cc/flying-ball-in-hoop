clear all
params_init;

trajStab_NE = true; 
%%
n = 3;
R = 1;
% Q = zeros(n);
Q = 10*diag([1e-3 1e-3 1e-3]);

psi_des = -70/180*pi;
x0 = [0;psi_des; 0];
% xf = x0;
xf = [0;0;0];

x = sym('x', [n, 1], 'real');
u = sym('u', [1, 1], 'real');
l = sym('l', [n, 1], 'real');
% Q = sym('Q', [n, n], 'real');
% Q = triu(Q,1) + triu(Q,0).';
% R = sym('R', [1, 1], 'real');
% R = triu(R,1) + triu(R,0).';

f = @(x, u) ballInAHoop3_ODEFUN(x, u, prms);

L = 1/2*x'*Q*x + 1/2*u'*R*u;
H = L + l'*f(x, u);

fx = jacobian(f(x, u), x);
fu = jacobian(f(x, u), u);

phi = 0;
psi = x-xf;
%% Form and solve the Two-Point boundary value problem
disp('Trajectory optimization')
u_of_lambda = solve(diff(H, u), u);
u_of_lambda = matlabFunction(u_of_lambda, 'Vars', {x, l});

dx = f(x, u_of_lambda(x, l));
dl = gradient(-H, x);
ode_sym = [dx;dl];

t_in = sym('t_in', 1, 'real');
ode_fun = matlabFunction(ode_sym, 'Vars', {t_in, [x; l]});

bc_fun = @(z0, zf) [z0(1:n,:) - x0; zf(1:n) - xf ];

t = linspace(0,1, 50);

solopts = []; %bvpset('NMax',51)
solinit = bvpinit(t,zeros(2*n,1));
sol = bvp4c(ode_fun, bc_fun,solinit,solopts);
%% Plot the optimal trajectory
t_star = sol.x;
x_star = sol.y(1:n,:)';
l_star = sol.y((n+1):2*n,:)';
u_star = u_of_lambda(x_star', l_star')';

figure(1)
clf
subplot(211)
plot(t_star, x_star)
grid on
xlabel('Time [s]')
ylabel('States [-]')
lh = legend('$\dot{\theta}(t)$ [rad/s]', '$\psi(t)$ [rad]', '$\dot{\psi}(t)$ [rad/s]');
set(lh, 'Interpreter', 'latex');

subplot(212)
plot(t_star, u_star)
grid on
xlabel('Time [s]')
ylabel('Control [-]')
lh = legend('$\tau(t)$');
set(lh, 'Interpreter', 'latex');
%% Neighboring Extremals
Hx = gradient(H, x);
Hxx = jacobian(Hx, x);
Hu = gradient(H, u);
Huu = jacobian(Hu, u);
Hxu = jacobian(Hx, u);
Hux = Hxu';

At = fx - fu*inv(Huu)*Hux;
Bt = fu*inv(Huu)*fu';
Ct = Hxx - Hxu*inv(Huu)*Hux;

fx_fun = matlabFunction(fx, 'Vars', {x, u});
fu_fun = matlabFunction(fu, 'Vars', {x, u});

Hxx_fun = matlabFunction(Hxx, 'Vars', {x, l, u});
Hux_fun = matlabFunction(Hux, 'Vars', {x, l, u});
Huu_fun = matlabFunction(Huu, 'Vars', {x, l, u});

At_fun = matlabFunction(At, 'Vars', {x, l, u});
Bt_fun = matlabFunction(Bt, 'Vars', {x, l, u});
Ct_fun = matlabFunction(Ct, 'Vars', {x, l, u});

%%
disp('Neighboring Extremals')
Sf = zeros(n);
Rf = eye(n);
Qf = zeros(n);

ti = 0; tf = 1;
opt = odeset('AbsTol',1.0e-07,'RelTol',1.0e-07);
% opt = [];
disp('- solve Riccati equation')

if ~trajStab_NE
    Qts = diag([1 10 1]);
    [tS,S] = ode45( @(t, S) dre_odeQ(t, S, At_fun, Bt_fun, Qts, t_star, x_star, l_star, u_star), [tf,ti], Sf, opt);
    tS = tS(end:-1:1);
    S = S(end:-1:1, :);
    S = reshape(S, size(S,1), 3, 3);
    
    K = zeros(size(S,1), 3);
    for i=1:size(S,1)
        K(i,:) = -inv(Huu)*(Hux + double(fu)'*squeeze(S(i,:,:)));
    end
    tK = tS;
else
    [tSRQ,SRQ] = ode45( @(t, S) dre_odeSRQ(t, S, At_fun, Bt_fun, Ct_fun, t_star, x_star, l_star, u_star), [tf,ti], [Sf(:);Rf(:);Qf(:)], opt);
    tSRQ = tSRQ(end:-1:1);
    SRQ = SRQ(end:-1:1, :);
    S = reshape(SRQ(:, 1:n*n), size(SRQ,1), n, n);
    R = reshape(SRQ(:, n*n+1:2*n*n), size(SRQ,1), n, n);
    Q = reshape(SRQ(:, 2*n*n+1:3*n*n), size(SRQ,1), n, n);
    
    disp('- extract the feedback gain')
    K = zeros(size(S,1), 3);
    for i=1:size(S,1)
        Si = squeeze(S(i,:,:));
        Ri = squeeze(R(i,:,:));
        Qi = squeeze(Q(i,:,:));
%         K(i,:) = -inv(Huu)*(Hux + double(fu)'*(Si - Ri/Qi*Ri' ));
        K(i,:) = -inv(Huu)*(Hux + double(fu)'*Si);
    end
    tK = tSRQ;
end

%% Simulation
disp('Simulation')
xd = [1;-30/180*pi;0];
[t_ne, x_ne] = ode45( @(t, x) ballInAHoop3K_ODEFUN(t, x, t_star, x_star, u_star, tK, K, prms), [ti, tf], x0+xd, opt);

figure(3)
clf
subplot(211)
plot(t_star, x_star, t_ne, x_ne, '--')
grid on
xlabel('Time [s]')
ylabel('States [-]')
lh = legend('$\dot{\theta}(t)$ [rad/s]', '$\psi(t)$ [rad]', '$\dot{\psi}(t)$ [rad/s]');
set(lh, 'Interpreter', 'latex');
ylim([-15 15])

subplot(212)
plot(t_star, u_star)
grid on
xlabel('Time [s]')
ylabel('Control [-]')
lh = legend('$\tau(t)$');
set(lh, 'Interpreter', 'latex');