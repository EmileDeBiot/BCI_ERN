% Clear the workspace and the screen
close all;
clear;
sca;

data_path = 'data/data/';
model_path = 'data/models/';
result_path = 'data/results/';
resource_path = 'data/resources/';

global_model_file = 'global_model';

cap = 64;
prediction_frequency = 10;

is_test = true;

%% BioSemi triggers
% 120: left good
% 122: right good
% 150: left bad
% 155: right bad
% 200: cross
% 201: stim
% 202: decision
% 203: feedback

% Open Biosemi to LSL connection
LibHandle = lsl_loadlib();
[Streaminfos] = lsl_resolve_all(LibHandle);

if ~is_test
    %% Init BCI
    % load BCILAB
    init_bci_lab;
    if isempty(Streaminfos)
        cd BioSemi
        system(strcat('BioSemi.exe -c my_config',num2str(cap),'.cfg &'));
        cd ..
        disp('Waiting for you to connect the BioSemi to LSL...');
    end
    while isempty(Streaminfos)
        [Streaminfos] = lsl_resolve_all(LibHandle);
    end
    disp('The BioSemi is linked to LSL');

    % Open recorder
    cd LabRecorder
    system('LabRecorder.exe -c my_config.cfg &');
    cd ..;

    %% Visualization
    vis_stream('BioSemi',10,5,150,1:1+cap+8,100,10);

    %% Loading files
    disp('Loading model...')
    global_file = io_load(strcat(model_path,global_model_file));

    disp("Starting the outlet...");
    [bci_outlet,  opts] = init_outlet_global('GlobalModel',global_file.model, 'SourceStream','BioSemi','LabStreamName','BCI','OutputForm','expectation','UpdateFrequency',prediction_frequency);
    
    disp('Initializing the robotic hands...');
    hands = init_hands();

    onl_write_background( ...
    'ResultWriter',@(y)action(hands, y, bci_outlet),...
    'MatlabStream',opts.in_stream, ...
    'Model',global_file.model, ...
    'OutputFormat',opts.out_form, ...
    'UpdateFrequency',opts.update_freq, ...
    'PredictorName',opts.pred_name, ...
    'PredictAt',opts.predict_at, ...
    'Verbose',opts.verbose, ...
    'StartDelay',0,...
    'EmptyResultValue',[]);

    % Ask for session number
    session_number = input('Session number: ', 's');

    % Ask for participant number
    participant_number = input('Participant number: ', 's');
end

% Initializing connetion to trigger serial port Biosemi
IOPort('CloseAll');
port = 'COM4';
[handle, errmsg] = IOPort('OpenSerialPort', port);

% Set up the keyboard
KbName('UnifyKeyNames');
escapeKey=KbName('ESCAPE');
leftKey=KbName('LeftArrow');
rightKey=KbName('RightArrow');

% PTB setup for flankersCloud task

Screen('Preference', 'SkipSyncTests', 0);

opacity = 0.8;
PsychDebugWindowConfiguration([], opacity)

% Initialize grey
white = WhiteIndex(0);
black = BlackIndex(0);
grey = white / 2;
% Open the screen
[window, windowRect] = PsychImaging('OpenWindow', 0, grey);
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');


% Get the size of the on screen window
[width, height]= Screen('WindowSize', window);
margin = 300;

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);
% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Set the text size
Screen('TextSize', window, 50);

% Set the duration of the stimuli
cross_duration = round(1.5/ifi);
flanker_duration = round(0.3/ifi);
afterTrialInterval = round(2/ifi);
feedback_duration = round(1/ifi);
decision_duration = round(5/ifi);
check_decision_duration = round(2/ifi);
press_duration = 4;

% Generate the flanker stimuli
rCongruent = 0.25;
rIncongruent = 0.25;
rRandom = 0.25;
rNeutral = 0.25;
nTrials = 2;
trials = flankersCloud(rCongruent, rIncongruent, rRandom, rNeutral, nTrials);

% Set up the timing
interTrialInterval=1;

% Set up the data
data=nan(nTrials, 4);

% Activate robotic hands
if ~is_test
    activate(hands);
end

DrawFormattedText(window, 'Press any key to start', 'center', 'center', [1 0 0]);
Screen('Flip', window);
KbStrokeWait;
vbl = Screen('Flip', window); % initial flip
% Run the flankers tasks
for trial = 1:nTrials
    % Fixation cross
    [img, ~, alpha]=imread(strcat(resource_path,'cross.png'));
    img(:,:,4) = alpha;
    cross = Screen('MakeTexture', window, img);
    Screen('DrawTexture', window, cross, [],[],0);
    
    % Send cross trigger
    [nwritten, when, errmsg, prewritetime, postwritetime, lastchecktime] = IOPort('Write', handle, {num2str(200)});

    vbl = Screen('Flip', window, vbl + (afterTrialInterval - 0.5) * ifi);

    nArrows = randi([8,15]);
    arrowSizes = randperm(15, nArrows)*10;
    arrowSizes = sort(arrowSizes, 'descend');
    margin=300;
    indices = randperm(20,nArrows);

    % Initializing the positions of the arrows
    positions = zeros(nArrows, 2);
    for j=1:nArrows
        r = mod(indices(j), 5);
        q = floor(indices(j)/5);
        positions(j, 1)=r*(width-2*margin)/4 + margin;
        positions(j, 2)=q*(height-2*margin)/3 + margin;
    end

    % Initializing the directions of the arrows
    random=randi(2);
    if trials(trial)==1
        arrowDirections=random*ones(1, nArrows); % All arrows in the same direction
    elseif trials(trial)==2
        if random==1
            arrowDirections=[1 2*ones(1, nArrows-1)]; % All arrows in the same direction except the first one
        else
            arrowDirections=[2 1*ones(1, nArrows-1)];
        end
    elseif trials(trial)==3
        arrowDirections=randi(2, 1, nArrows); % Random directions
    elseif trials(trial)==4
        arrowDirections=randi(2, 1, nArrows); % Random direction for the middle arrow, other arrows will be replaced by neutral symbols
    end


    % Flanker stimuli
    for j=1:nArrows
        if arrowDirections(j)==1
            [img, ~, alpha]=imread(strcat(resource_path,'left.png'));
            img(:,:,4) = alpha;
            arrow=Screen('MakeTexture', window, img);
        else
            [img, ~, alpha]=imread(strcat(resource_path,'right.png'));
            img(:,:,4) = alpha;
            arrow=Screen('MakeTexture', window, img);
        end
        Screen('DrawTexture', window, arrow, [], [positions(j, 1)-arrowSizes(j)/2, positions(j, 2)-arrowSizes(j)/2, positions(j, 1)+arrowSizes(j)/2, positions(j, 2)+arrowSizes(j)/2]);
    end
    % Send stimulus trigger
    [nwritten, when, errmsg, prewritetime, postwritetime, lastchecktime] = IOPort('Write', handle, {num2str(201)});

    vbl = Screen('Flip', window, postwritetime);
    
    % Wait for the hand activation
    Screen('FillRect', window, grey);
    vbl = Screen('Flip', window, vbl + (flanker_duration - 0.5) * ifi);

    % Ask for the decision
    Screen('TextSize', window, 70);
    DrawFormattedText(window, 'Make your move!', 'center',...
        height * 0.50, [1 0 0]);
    
    vbl = Screen('Flip', window, vbl + (flanker_duration - 0.5) * ifi);

    tStart=GetSecs;
    response = 0;
    while GetSecs-tStart<press_duration
        [keyIsDown, tEnd, keyCode]=KbCheck;
        if keyIsDown
            if keyCode(escapeKey)
                sca;
                return
            elseif keyCode(leftKey)
                response=1;
                break
            elseif keyCode(rightKey)
                response=2;
                break
            end
        end
    end

    % Send triggers
    if response==1
        if arrowDirections(1)==1
            outcome = 120;
            [nwritten, when, errmsg, prewritetime, postwritetime, lastchecktime] = IOPort('Write', handle, {num2str(120)});
        else
            outcome = 150;
            [nwritten, when, errmsg, prewritetime, postwritetime, lastchecktime] = IOPort('Write', handle, {num2str(150)});
        end
    elseif response==2
        if arrowDirections(1)==2
            outcome = 122;
            [nwritten, when, errmsg, prewritetime, postwritetime, lastchecktime] = IOPort('Write', handle, {num2str(122)});
        else
            outcome = 155;
            [nwritten, when, errmsg, prewritetime, postwritetime, lastchecktime] = IOPort('Write', handle, {num2str(155)});
        end
    else
        outcome = 130;
        [nwritten, when, errmsg, prewritetime, postwritetime, lastchecktime] = IOPort('Write', handle, {num2str(130)});
    end
    
    if ~is_test
        deactivate(hands);
    end
    % Ask if it was the decision they wanted to take
    Screen('TextSize', window, 70);
    if outcome == 120 || outcome == 50
        [img, ~, alpha]=imread(strcat(resource_path,'left.png'));
        img(:,:,4) = alpha;
        arrow = Screen('MakeTexture', window, img);
        DrawFormattedText(window, 'You chose', 'center',...
            height * 0.25, [1 0 0]);
    elseif outcome == 122 || outcome == 155
        [img, ~, alpha]=imread(strcat(resource_path,'right.png'));
        img(:,:,4) = alpha;
        arrow = Screen('MakeTexture', window, img);
        DrawFormattedText(window, 'You chose', 'center',...
            height * 0.25, [1 0 0]);
    elseif outcome == 130
        DrawFormattedText(window, 'No response', 'center',...
            height * 0.25, [1 0 0]);
    end
    DrawFormattedText(window, 'Was it the decision you wanted to make?', 'center',...
        height * 0.50, [1 0 0]);
    DrawFormattedText(window, 'Yes (y) or No (n)', 'center',...
        height * 0.75, [1 0 0]);
    if outcome ~= 130
        Screen('DrawTexture', window, arrow, [], [width/2 + 200, height * 0.25 - 75, width/2+300, height * 0.25 + 25]);
    end
    Screen('Flip', window, vbl + (decision_duration - 0.5) * ifi);

    while true
        [keyIsDown, tEnd, keyCode]=KbCheck;
        if keyIsDown
            if keyCode(escapeKey)
                sca;
                return
            elseif keyCode(KbName('y'))
                break
            elseif keyCode(KbName('n'))
                break
            end
        end
    end

    % Fixation cross
    vbl = Screen('Flip', window, vbl + (check_decision_duration - 0.5) * ifi);
    Screen('DrawTexture', window, cross, [],[],0);
    vbl = Screen('Flip', window, vbl + (cross_duration - 0.5) * ifi);

    % Show feedback
    if outcome == 120
        [img, ~, alpha]=imread(strcat(resource_path,'check.png'));
        img(:,:,4) = alpha;
        feedback = Screen('MakeTexture', window, img);
        Screen('DrawTexture', window, feedback, [],[],0);
    elseif outcome == 150
        [img, ~, alpha]=imread(strcat(resource_path,'wrong.png'));
        img(:,:,4) = alpha;
        feedback = Screen('MakeTexture', window, img);
        Screen('DrawTexture', window, feedback, [],[],0);
    elseif outcome == 122
        [img, ~, alpha]=imread(strcat(resource_path,'check.png'));
        img(:,:,4) = alpha;
        feedback = Screen('MakeTexture', window, img);
        Screen('DrawTexture', window, feedback, [],[],0);
    elseif outcome == 155
        [img, ~, alpha]=imread(strcat(resource_path,'wrong.png'));
        img(:,:,4) = alpha;
        feedback = Screen('MakeTexture', window, img);
        Screen('DrawTexture', window, feedback, [],[],0);
    else
        DrawFormattedText(window, 'No response', 'center',...
            height * 0.50, [1 0 0]);
    end
    
    % Send trigger for feedback
    [nwritten, when, errmsg, prewritetime, postwritetime, lastchecktime] = IOPort('Write', handle, {num2str(202)});
    vbl = Screen('Flip', window, postwritetime);

    %% Show the arrows and circle the biggest one
    for j=1:nArrows
        if arrowDirections(j)==1
            [img, ~, alpha]=imread(strcat(resource_path,'left.png'));
            img(:,:,4) = alpha;
            arrow=Screen('MakeTexture', window, img);
        else
            [img, ~, alpha]=imread(strcat(resource_path,'right.png'));
            img(:,:,4) = alpha;
            arrow=Screen('MakeTexture', window, img);
        end
        Screen('DrawTexture', window, arrow, [], [positions(j, 1)-arrowSizes(j)/2, positions(j, 2)-arrowSizes(j)/2, positions(j, 1)+arrowSizes(j)/2, positions(j, 2)+arrowSizes(j)/2]);
    end
    % Circle the biggest arrow, the first one
    Screen('FrameOval', window, white, [positions(1, 1)-arrowSizes(1)/2 - 20, positions(1, 2)-arrowSizes(1)/2 - 20, positions(1, 1) + arrowSizes(1)/2 + 20, positions(1, 2)+ arrowSizes(1)/2 + 20], 10);

    vbl = Screen('Flip', window, vbl + (afterTrialInterval - 0.5) * ifi);

    % Store the data
    data(trial, 1) = trials(trial);
    data(trial, 2) = response;
    data(trial, 3) = arrowDirections(1);
    data(trial, 4) = outcome;

    if ~is_test
        activate(hands);
    end
end

% save the data
if ~is_test
    filename = strcat(data_path, 'S', session_number, '_P', participant_number, '.mat');
    save(strcat(data_path, 'flankers_data.mat'), 'data');
end
sca;