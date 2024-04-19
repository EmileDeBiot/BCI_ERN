function feedback_session(threshold, modelFile, testedHand)
    % feedback_session: Run a feedback session with the given model and hand
    %   threshold: The threshold for the feedback
    %   modelFile: The file containing the model
    %   testedHand: The hand to test
    model_path = 'data/models/';

    close all;
    cap = 64;
    prediction_frequency = 10;
    thresholds = [0.2 threshold 1];

    %% Init
    % load BCILAB
    init_bci;

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
    disp('The BioSemi is linked to LSL');

    %% Feedback
    file = io_load(strcat(model_path,modelFile));
    model = file.model;
   
    run_readlsl('MatlabStream','BioSemi','DataStreamQuery','name=''BioSemi''','MarkerStreamQuery',['']);
    run_robotic_hand('Model',model, 'Hand', testedHand, 'SourceStream','BioSemi','LabStreamName','BCI','OutputForm','expectation','UpdateFrequency',prediction_frequency,'hold_hand',1,'thresholds',thresholds);
    %run_write_robotic_hand('Model',model,'SourceStream','BioSemi','LabStreamName','BCI','OutputForm','expectation','UpdateFrequency',prediction_frequency,'hold_hand',1,'thresholds',thresholds);

    %% Visualization
    vis_stream('BioSemi',10,5,150,1:1+cap+8,100,10);
    vis_stream('BCI',10,5,150,1,100,10);

    %% Clear
    input('Press a key to finish the session...');
    onl_clear;
    close all; 
end