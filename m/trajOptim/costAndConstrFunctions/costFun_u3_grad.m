function grad = costFun_u3_grad( z, xf_des, N )

u = z(5:5:end);
grad = zeros(5*N+1,1);
grad(5:5:end) = 2*u;

dpsi = z(4:5:end);
I = floor(N/2);
grad(4 + (I-1)*5) = -0.004*2*dpsi(I);

end

