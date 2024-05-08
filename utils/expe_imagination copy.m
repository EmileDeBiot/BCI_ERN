function expe_imagination(markers,nbtrials_per_marker,cross_delay,arrow_delay,imagination_delay,rest_delay,LibHandle,show_feedback_to_user,prediction_frequency)
    % Run an experiment for BCI training
    % Inputs:
    % - markers: cell array of strings, the classes to be trained
    % - nbtrials_per_marker: integer, the number of trials per class
    % - cross_delay: integer or 2-elements vector, the delay between the fixation cross and the arrow
    % - arrow_delay: integer or 2-elements vector, the delay between the arrow and the imagery
    % - imagination_delay: integer or 2-elements vector, the delay between the imagery and the rest
    % - rest_delay: integer or 2-elements vector, the delay between the rest and the next trial
    % - LibHandle: the handle to the LSL library
    % - show_feedback_to_user: boolean, whether to show the feedback to the user
    % - prediction_frequency: integer, the frequency at which the prediction is made
    global_model_file = 'global_model';
    data_path = 'data/data/';
    model_path = 'data/models/';

    % Check input
    rest_class = false;
    for i = 1:length(markers)
        if ~strcmp(markers{i},'left') && ~strcmp(markers{i},'right') && ~strcmp(markers{i},'rest') && ~strcmp(markers{i},'tongue')
            error('Markers should be chosen in the following list: ''left'',''right'',''rest'',''tongue''')
        end
        if strcmp(markers{i},'rest')
            rest_class = true;
        end
    end
    if rest_class
        nb_classes = length(markers);
    else
        nb_classes = length(markers)+1;
    end

    % LSL
    info = lsl_streaminfo(LibHandle,'MyMarkerStream','Markers',1,0,'cf_string','myuniquesourceid23443');
    marker_outlet = lsl_outlet(info);
    if show_feedback_to_user
        [hands, config] = init_hands('COM12');
        global_file = io_load(strcat(model_path,global_model_file));
        [result_outlet,  opts] = init_outlet_global('GlobalModel',global_file.model, 'SourceStream','BioSemi','LabStreamName','BCI','OutputForm','expectation','UpdateFrequency',prediction_frequency)
        onl_write_background(...
            'ResultWriter',@(y)activate(hands, config, result_outlet, y),...
            'MatlabStream',opts.in_stream, ...
            'Model',global_file.model, ...
            'OutputFormat',opts.out_form, ...
            'UpdateFrequency',opts.update_freq, ...
            'PredictorName',opts.pred_name, ...
            'PredictAt',opts.predict_at, ...
            'Verbose',opts.verbose, ...
            'StartDelay',0,...
            'EmptyResultValue',[]);
    end

    % Graphics settings
    
    % Here we call some default settings for setting up Psychtoolbox
    Screen('Preference', 'SkipSyncTests', 1);
    PsychDefaultSetup(2);
    % Get the screen numbers
    screens = Screen('Screens');
    % Draw to the external screen if avaliable
    screenNumber = max(screens);
    if screenNumber ~= 2
        error('External screen is not connected! Connect it and restart Matlab.')
    end
    % Define black and white (white will be 1 and black 0). This is because
    % in general luminace values are defined between 0 and 1 with 255 steps in
    % between. All values in Psychtoolbox are defined between 0 and 1
    white = WhiteIndex(screenNumber);
    black = BlackIndex(screenNumber);
    % Do a simply calculation to calculate the luminance value for grey. This
    % will be half the luminace values for white
    grey = white / 2;
    % Open an on screen window
    [window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);
    % Get the size of the on screen window
    [screenXpixels, screenYpixels] = Screen('WindowSize', window);
    % Query the frame duration
    cycleRefresh = Screen('GetFlipInterval', window);
    % Set up alpha-blending for smooth (anti-aliased) lines
    Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    % Setup the text type for the window
    Screen('TextFont', window, 'Ariel');
    Screen('TextSize', window, 36);
    % Get the centre coordinate of the window
    [xCenter, yCenter] = RectCenter(windowRect);
    % Here we set the size of the arms of our fixation cross
    fixCrossDimPix = screenYpixels/4;
    % Now we set the coordinates (these are all relative to zero we will let
    % the drawing routine center the cross in the center of our monitor for us)
    xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
    yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
    allCoords = [xCoords; yCoords];
    % Set the line width for our fixation cross
    lineWidthPix = 4;
    % Set the dimensions of the arrow
    Width = fixCrossDimPix*0.25;
    Length = fixCrossDimPix*0.5;
    % Set the color of the rect to red and feedback to green
    rectColor = [1 0 0];
    feedbackColor = [0 1 0];
    % Cue to tell PTB that the polygon is convex (concave polygons require much
    % more processing)
    isConvex = 1;

    % Experiment

    % Generate a random succession of trials with as equal number of trials for
    % each class
    trials = repmat(markers,1,nbtrials_per_marker);
    trials = trials(randperm(length(trials)));

    % vbl = Screen('Flip', window);
    trial = 1;
    
    DrawFormattedText(window, 'Ready?', 'center', 'center', [54,54,54]);
    Screen('Flip', window);
    [secs, keyCode, deltaSecs] = KbWait;
    while ~strcmp(strcat(KbName(keyCode)),'Return')
        [secs, keyCode, deltaSecs] = KbWait; 
    end
    
    % What we want to do is to simulate nb_trials_per_marker for each hand
    % and label 'rest' the rest of the signal

    while trial<=length(trials)

        if length(cross_delay) == 2
            delay = randi(cross_delay)/1000;
        else
            delay = cross_delay/1000;
        end
        timerVal1 = tic;
        
        marker_outlet.push_sample({'cross'});

        % Display fixation cross
        while toc(timerVal1) < delay
            Screen('DrawLines', window, allCoords,lineWidthPix, white, [xCenter yCenter], 2);
            Screen('Flip', window);
        end
        

        % Displaying Fixation cross + Arrow
        Screen('DrawLines', window, allCoords,lineWidthPix, white, [xCenter yCenter], 2);

        if  strcmp(trials(trial),'right')
            RectVector = [xCenter , xCenter + Length, xCenter + Length, xCenter; ...
                          yCenter - Width/2, yCenter - Width/2, yCenter + Width/2, yCenter + Width/2];
            TriangleVector = [xCenter + Length, xCenter + 1.2*Length, xCenter + Length; ...
                          yCenter - 1.5*Width/2, yCenter, yCenter + 1.5*Width/2];
        else
            RectVector = [xCenter - Length , xCenter, xCenter, xCenter - Length; ...
                          yCenter - Width/2, yCenter - Width/2, yCenter + Width/2, yCenter + Width/2];
            TriangleVector = [xCenter - Length, xCenter - 1.2*Length, xCenter - Length; ...
                          yCenter - 1.5*Width/2, yCenter, yCenter + 1.5*Width/2];
        end
        
        marker = trials(trial);
        marker_outlet.push_sample(marker);

        if length(arrow_delay) == 2
            delay = randi(arrow_delay)/1000;
        else
            delay = arrow_delay/1000;
        end

        timerVal1 = tic;
        % Draw the arrow
        while toc(timerVal1) < delay
            Screen('DrawLines', window, allCoords,lineWidthPix, white, [xCenter yCenter], 2);
            Screen('FillPoly', window, rectColor, RectVector', isConvex);
            Screen('FillPoly', window, rectColor, TriangleVector', isConvex);
            Screen('Flip', window);
        end

        % Fixation cross
        
        marker_outlet.push_sample({'imagery'});
        if length(imagination_delay) == 2
            delay = randi(imagination_delay)/1000;
        else
            delay = imagination_delay/1000;
        end
        timerVal1 = tic;
        while toc(timerVal1) < delay
            Screen('DrawLines', window, allCoords,lineWidthPix, white, [xCenter yCenter], 2);
            Screen('Flip', window);
        end

        % Nothing
        
        marker_outlet.push_sample({'pause'});
        if length(rest_delay) == 2
            delay = randi(rest_delay)/1000;
        else
            delay = rest_delay/1000;
        end
        timerVal1 = tic;
        while toc(timerVal1) < delay
             Screen('Flip', window);
             [keyIsDown, secs, keyCode, deltaSecs] = KbCheck(0);
             if strcmp(KbName(find(keyCode)),'ESCAPE')
                 trial = length(trials)+1;
             end
        end
        trial = trial + 1;
        disp(trial);
    end
    Screen('CloseAll');

end