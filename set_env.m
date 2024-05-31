addpath('utils/');
addpath('robotic_hands/');
addpath('test/');
addpath('exp_paradigms/');

%check if the data paths exists
if ~exist('data/data/', 'dir')
    mkdir('data/data/');
end
if ~exist('data/models/', 'dir')
    mkdir('data/models/');
end
if ~exist('data/results/', 'dir')
    mkdir('data/results/');
end
%% adding relevant toolboxes to the path
% biosig toolbox
addpath(matlabroot,'toolbox/biosig/t200_FileAccess"');
addpath(matlabroot,'toolbox/biosig/t250_ArtifactPreProcessingQualityControl"');


disp('Add psychtoolbox to the path.')
disp('Remember to move the PsychBasic/MatlabWindowsFilesR2007a folder above the PsychBasic/ folder in the path.')

% wait for enter to continue
disp('Press enter to continue.')
pause
% create a savepath file
edit pathdef.m
savepath
% testing hands
disp('Verifiy the usb port of the arduino Uno board')

% prompt user to enter the usb port of the arduino board
port = input('Enter the usb port of the arduino board in format COM12: ', 's');

% save the com port to a json file
config = readstruct('robotic_hands/hands_config.json');
disp(config)
config.port = port;
writestruct(config, 'robotic_hands/hands_config.json');
disp('Press enter to test hands.')
pause
disp('You should see the indexes of the two hands press the keys.')
test_activation()
