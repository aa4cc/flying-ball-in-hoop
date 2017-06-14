clear all
clc

addpath('../../raspi');
addpath('../../');
params_init;

expNum = 1;
%%
% Connect to raspberry pi and capture a snapshot of the steady hw setup.
mypi = raspi(ip_rpi, 'pi', 'mamradtisk');
% cameraboard() doesn't allow to set the resolution to 480x480 hence the
% closest larger is chosen and the captured image is cropepd later on
mycam = cameraboard(mypi,'Resolution','640x480');
% Configure the pin for turning on and off the light
configurePin(mypi, 21,'DigitalOutput');

% Turn on the light
writeDigitalPin(mypi, 21, 1)

N = 1;
for i=1:N
    % Take a snapshot
    img = snapshot(mycam);
    % Crop it to 480x480
    img = img(:,81:560,:);

    imshow(img);
    title(sprintf('Frame %d/%d', i, N))
    pause(2)
end
% Turn off the light
writeDigitalPin(mypi, 21, 0)

% Disconnect from the raspi
clear mycam

% Store the last captured image
imwrite(img, sprintf('meas_pos%02d.png', expNum));
%%
open('hoop_ident.slx')

simul_time = 15;
fps = 50;
num_frames = round(50*(simul_time+30));
stream = 0;
exposition_time = 5;

% run the script measuring the position on raspi
rpi_posMes_run( mypi, fps, num_frames, stream, exposition_time )
pause(2)

% sim('bldc_posMeas.slx')
set_param('hoop_ident', 'SimulationCommand', 'start')
pause(simul_time+2)

clear mypi
%%
meas_pos.Time = measData.time;
[x, y] = measData.signals.values;
meas_pos.Data = [x, y]';
save(sprintf('meas_pos%02d.mat', expNum), 'meas_pos')