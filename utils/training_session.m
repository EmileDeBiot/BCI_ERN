function training_session(previousModel, testedHand, nbTrialsPerHand, crossDelay, arrowDelay, imaginationDelay, restDelay, predictionFrequency)
    % training_session: Run a training session with the given hand
    %   previousModel: The previous model to use
    %   testedHand: The hand to test
    %   nbTrialsPerHand: The number of trials per hand
    %   crossDelay: The delay between the cross and the arrow
    %   arrowDelay: The delay between the arrow and the imagination
    %   imaginationDelay: The delay between the imagination and the rest
    %   restDelay: The delay between the rest and the cross
    %   predictionFrequency: The prediction frequency
    
    model_path = 'data/models/';
    
    cap = 64;
    if strcmp(testedHand, 'both')
        markers = {'left', 'right','rest'};
    else
        markers = {testedHand, 'rest'};
    end
    show_feedback_to_user = false; % ok only for (rest vs) right and left vs (rest vs) right
    
    %% Init

    % load BCILAB
    init_bci_lab;

    % Open Biosemi to LSL connection
    LibHandle = lsl_loadlib();
    [Streaminfos] = lsl_resolve_all(LibHandle);
    if isempty(Streaminfos)
        cd BioSemi
        system(strcat('BioSemi.exe -c my_config',num2str(cap),'.cfg &'));
        cd ..
        disp('Waiting for you to connect the BioSemi to LSL...');
    end
    while isempty(Streaminfos)
        [Streaminfos] = lsl_resolve_all(LibHandle);
    end
    disp('The BioSemi is linked to LSL')

    % Open recorder
    cd LabRecorder
    system('LabRecorder.exe -c my_config.cfg &');
    cd ..;

    %% Feedback
    previousModel = char(previousModel);
    if ~isempty(previousModel)
        model_file = io_load(strcat(model_path,previousModel));
        model = model_file.model;
        run_readlsl('MatlabStream','BioSemi','DataStreamQuery','name=''BioSemi''','MarkerStreamQuery',['']);
        run_writelsl('Model',model,'SourceStream','BioSemi','LabStreamName','BCI','OutputForm','expectation','UpdateFrequency',predictionFrequency);
    end

    %% Visualization
    vis_stream('BioSemi',10,5,150,1:1+cap+8,100,10);
    if ~isempty(previousModel)
        vis_stream('BCI',10,5,150,1,100,10);
    end

    %% Experiment
    training(markers,nbTrialsPerHand,crossDelay,arrowDelay,imaginationDelay,restDelay,LibHandle,show_feedback_to_user,predictionFrequency);

    %% Clear
    % lib = lsl_resolve_all(LibHandle);
    if ~isempty(previousModel)
        onl_clear;
    end
    close all;