function test_flankersCloud(nTrials, signalDuration, responseDuration)
    % Run a flankers experiment
    % nTrials: number of trials
    % signalDuration: duration of the stimulus presentation in seconds

    resourcesPath="data/resources/";
    % Set up the screen
    Screen('Preference', 'SkipSyncTests', 0);
    w=Screen('OpenWindow',0); % change window number
    
    cycleRefresh=Screen('GetFlipInterval', w);

    vbl=Screen(w, 'Flip');
    [width, height]=Screen('WindowSize', w);

    % Set up the keyboard
    KbName('UnifyKeyNames');
    escapeKey=KbName('ESCAPE');
    leftKey=KbName('LeftArrow');
    rightKey=KbName('RightArrow');

    % Set up the stimuli
    nCongruent  = 0.2*nTrials;
    nIncongruent= 0.2*nTrials;
    nRandom     = 0.5*nTrials;
    nNeutral    = 0.1*nTrials;

    trials = [ones(1,nCongruent) 2*ones(1,nIncongruent) 3*ones(1,nRandom) 4*ones(1,nNeutral)];
    trials = trials(randperm(nTrials));



    

    % Set up the timing
    interTrialInterval=1;

    % Set up the data
    data=nan(nTrials, 4);

    % Run the experiment

    for trial=1:nTrials
        nArrows = randi([8,15]);
        arrowSizes = randperm(15, nArrows)*10;
        arrowSizes = sort(arrowSizes, 'descend');
        margin=300;
        indices = randperm(20,nArrows);
        positions = zeros(nArrows, 2);
        for j=1:nArrows
            r = mod(indices(j), 5);
            q = floor(indices(j)/5);
            positions(j, 1)=r*(width-2*margin)/4 + margin;
            positions(j, 2)=q*(height-2*margin)/3 + margin;
        end

        arrowDirections=ones(nTrials, nArrows);

        % Set up the arrow directions
        % 1: left
        % 2: right
        for i=1:nTrials
            random=randi(2);
            if trials(i)==1
                arrowDirections(i, :)=random*ones(1, nArrows); % All arrows in the same direction
            elseif trials(i)==2
                if random==1
                    arrowDirections(i, :)=[1 2*ones(1, nArrows-1)]; % All arrows in the same direction except the middle one
                else
                    arrowDirections(i, :)=[2 1*ones(1, nArrows-1)];
                end
            elseif trials(i)==3
                arrowDirections(i, :)=randi(2, 1, nArrows); % Random directions
            elseif trials(i)==4
                arrowDirections(i, :)=randi(2, 1, nArrows); % Random direction for the middle arrow, other arrows will be replaced by neutral symbols
            end
        end
        % Inter-trial interval
        Screen('FillRect', w, 0);
        Screen('Flip', w);
        WaitSecs(interTrialInterval);

        % Stimulus
        for j=1:nArrows
            if arrowDirections(trial, j)==1
                arrow=Screen('MakeTexture', w, imread(strcat(resourcesPath,'left.png')));
            else
                arrow=Screen('MakeTexture', w, imread(strcat(resourcesPath,'right.png')));
            end
            Screen('DrawTexture', w, arrow, [], [positions(j, 1)-arrowSizes(j)/2, positions(j, 2)-arrowSizes(j)/2, positions(j, 1)+arrowSizes(j)/2, positions(j, 2)+arrowSizes(j)/2]);
        end
        Screen('Flip', w);
        WaitSecs(signalDuration);

        % Response
        Screen('FillRect', w, 0);
        Screen('Flip', w);
        tStart=GetSecs;
        response=0;
        while GetSecs-tStart<responseDuration
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
        data(i, 1)=trials(i);
        data(i, 2)=response;
        data(i, 3)=response-tStart;
        data(i, 4)=tEnd-tStart;
    end
    sca;
    disp(data);
end