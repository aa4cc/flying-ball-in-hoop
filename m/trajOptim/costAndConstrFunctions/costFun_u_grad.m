function grad = costFun_u_grad( z, xf_des, N )

u = z(5:5:end);
grad = zeros(5*N+1,1);
grad(5:5:end) = 2*u;


end

