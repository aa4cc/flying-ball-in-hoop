clear all
clc

addpath('../../raspi');
addpath('../../');
params_init;
load('calibData_hom.mat')

expNum = 1;
%%
% Connect to raspberry pi and capture a snapshot of the steady hw setup.
mypi = raspi(ip_rpi, 'pi', 'mamradtisk');
%%
open('ballOnly_ident.slx')

simul_time = 30;
fps = 50;
num_frames = round(50*(simul_time+30));
stream = 0;
exposition_time = 5;

% run the script measuring the position on raspi
rpi_posMes_run( mypi, fps, num_frames, stream, exposition_time )
pause(2)

% sim('bldc_posMeas.slx')
set_param('ballOnly_ident', 'SimulationCommand', 'start')
pause(simul_time+2)

clear mypi
%%
meas_pos.Time = measData.time;
[u, th, Dth, psi] = measData.signals.values;
meas_pos.Data = [u, th, Dth, psi];
save(sprintf('meas_ballOnly%02d.mat', expNum), 'meas_pos')
