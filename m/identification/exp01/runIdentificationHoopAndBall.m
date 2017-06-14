clear all
clc

addpath('../../raspi');
addpath('../../');
params_init;
load('calibData_hom.mat')   

expNum = 2;
%%
% Connect to raspberry pi and capture a snapshot of the steady hw setup.
mypi = raspi(ip_rpi, 'pi', 'mamradtisk');
%%
load('rollIt_N50_T1.5_umax1_0.mat')
[t, ~, u] = traj.interp(prms.Ts);

% The trajectory contains also the final time with zero input. That is
% something we do not need here
t = t(1:end-1,:);
u = 0.3*u(1:end-1,:);

u_TS = timeseries([0; u; 0; u], [0; t+2; t(end)+2; t+t(end)+3]);

%%

open('hoopAndBall_ident.slx')

simul_time = 20;
fps = 50;
num_frames = round(50*(simul_time+30));
stream = 0;
exposition_time = 5;

% run the script measuring the position on raspi
rpi_posMes_run( mypi, fps, num_frames, stream, exposition_time )
pause(2)

% sim('bldc_posMeas.slx')
set_param('hoopAndBall_ident', 'SimulationCommand', 'start')
pause(simul_time+2)

clear mypi
%%
meas_pos.Time = measData.time;
[u, th, Dth, psi] = measData.signals.values;
meas_pos.Data = [u, th, Dth, psi];
save(sprintf('meas_hoopAndBall%02d.mat', expNum), 'meas_pos')
