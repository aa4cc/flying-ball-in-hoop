function grad = costFun_u_grad( z, xf_des, N )

u = z(5:5:end);
grad = zeros(5*N+1,1);
grad(5:5:end) = 2*u;

dpsi = z(4:5:end);
grad(4:5:end) = -0.0007*2*dpsi;

end

