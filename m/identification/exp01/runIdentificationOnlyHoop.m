clear all
clc

addpath('../../raspi');
addpath('../../');
params_init;
load('calibData_hom.mat')

expNum = 2;
%%
ampl = 0.2;
freqStart = 0.15;
freqEnd = .5;

open('only_hoop_ident.slx')

set_param('only_hoop_ident', 'SimulationCommand', 'start')

%%
meas_pos.Time = measData.time;
[u, th, Dth, iq] = measData.signals.values;
meas_pos.Data = [u, th, Dth, iq];
% save(sprintf('meas_hoop%02d_f%02d_a%02d.mat', expNum, 10*freq, 10*ampl), 'meas_pos')
save(sprintf('meas_hoop%02d_chirp.mat', expNum), 'meas_pos')
