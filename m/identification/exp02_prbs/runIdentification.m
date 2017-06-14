clear all
clc

addpath('../../raspi');
addpath('../../');
params_init;

%%
N = 3;
for i=1:N
    imshow(loadImg(ip_host, ip_rpi));
    title(sprintf('Frame %d/%d', i, N))
    pause(.1)
end
%%
expNum = 1;
img = loadImg(ip_host, ip_rpi);
imwrite(img, sprintf('meas_pos%02d.png', expNum));

%%
open('hoop_ident.slx')
% load('old_uTf2N100_2.mat')

simul_time = 15;
fps = 50;
num_frames = round(50*(simul_time+30));
stream = 0;
exposition_time = 5;

% run the script measuring the position on raspi
rpi_posMes_run( fps, num_frames, stream, exposition_time, ip_rpi )
pause(2)

% sim('bldc_posMeas.slx')
set_param('hoop_ident', 'SimulationCommand', 'start')
pause(simul_time+2)
%%
%%
meas_pos.Time = measData.time;
[x, y] = measData.signals.values;
meas_pos.Data = [x, y]';
save(sprintf('meas_pos%02d.mat', expNum), 'meas_pos')
