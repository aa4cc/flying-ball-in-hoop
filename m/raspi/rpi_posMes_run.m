function rpi_posMes_run( mypi, fps, num_frames, stream, exposition_time )

if nargin < 3
    stream = 0;
end

if nargin < 4
    exposition_time = 10;
end


cmd = sprintf('taskset 0x08 ~/flying-ball/raspi-ballpos/posMeas.py -f %d -n %d -e %d -p', fps, num_frames, exposition_time);

if stream
    cmd = strcat(cmd, ' -s t');
end

cmd = strcat(cmd, ' &>/dev/null &');

system(mypi, cmd);

% 
% 
% %%
% P = mfilename('fullpath');
% [pathstr,~,~] = fileparts(P);
% 
% fileID = fopen(fullfile(pathstr, 'remoteCmds.txt'),'w');
% fprintf(fileID,'taskset 0x08 ~/flying-ball/raspi-ballpos/posMeas.py -f %d -n %d -e %d -p', fps, num_frames, exposition_time);
% 
% if stream
%     fprintf(fileID,' -s t');
% % end
% 
%  &>/dev/null &
% 
% system(mypi,'~/flying-ball/raspi-ballpos/posMeas.py -f 50 -n 200 -e 5 -p &>/dev/null &')

% fprintf(fileID,'\n');
% fclose(fileID);
%%
% plink_path = fullfile(pathstr, 'plink.exe');
% cert_path = fullfile(pathstr, 'key.ppk');
% cmds_path = fullfile(pathstr, 'remoteCmds.txt');

% system(sprintf('start /b %s -ssh pi@%s -i %s -m %s &', plink_path, ip_rpi, cert_path, cmds_path ))
%%
% Wait till the script starts
% pause(1)

% delete('remoteCmds.txt')

end

