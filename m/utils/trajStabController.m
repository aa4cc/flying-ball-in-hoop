function [ K ] = trajStabController( t_star, x_star, T, Q, Qf, R, prms )

%% Linearization around the optimal trajectory
a =  prms.out.a_bar;
b =  prms.out.b_bar;
c =  prms.out.c_bar;
d =  prms.out.d_bar;
e =  prms.out.e_bar;

% x := [Dth; psi; Dpsi]
A = zeros(numel(t_star), 3, 3);
B = zeros(numel(t_star), 3, 1);

%% Linearize the system along the trajectory
for i=1:numel(t_star)
    Ak_c = [0 0 0; 0 0 1; -d/a -c/a*cos(x_star(i,2+1)) -b/a]; % system matrix of the linearized continuous model
    Bk_c = [1;0;e/a];
    
    A(i,:,:) = eye(3) + T*Ak_c;
    B(i,:,:) = T*Bk_c;
end

%% Design a LQR stabilizying the trajectory
P = zeros(numel(t_star), 3, 3);
K = zeros(numel(t_star), 1, 3);

P(end,:,:) = Qf;

for i = size(P,1):-1:2
    At_prev = squeeze(A(i-1,:,:));
    Bt_prev = squeeze(B(i-1,:,:))';
    Pt = squeeze(P(i,:,:));
    
    Pt_prev = Q + At_prev'*Pt*At_prev - At_prev'*Pt*Bt_prev/(R+Bt_prev'*Pt*Bt_prev)*Bt_prev'*Pt*At_prev;
    Kt_prev = -(R+Bt_prev'*Pt*Bt_prev)\Bt_prev'*Pt*At_prev;
    
    P(i-1,:,:) = Pt_prev;
    K(i-1,:,:) = Kt_prev;
end


end

