function training_model(testedHand, files)
    % training_model: Train a model with the given files and hand
    %   testedHand: The hand to test
    %   files: The files to train the model with
    data_path = 'data/data/';
    model_path = 'data/models/';

    if strcmp(testedHand, 'both')
        markers = {'left', 'right'};
    elseif strcmp(testedHand, 'right')
        markers = {'cross','right'};
    elseif strcmp(testedHand, 'left')
        markers = {'cross','left'};
    end
    
    select_all_channel = false;
    artifact_correction = false;

    %% Init

    % load BCILAB
    init_bci;

    %% Channels
    biosemi_cfg = 64;
    wanted_channels = ... % if select_all_channel is false, following channels are selected
        {'C3','C1','C2','C4','Cz','FC3','FC1','FC2' ,'FC4','FCz','CP3','CP1','CP2','CP4','CPz'};
    % {'C5','C3','C1','C2','C4','C6','Cz','FC5','FC3','FC1','FC2','FC4','FC6','FCz','F5','F3','F1','F2','F4','F6','Fz','CP5','CP3','CP1','CP2','CP4','CP6','CPz','P5','P3','P1','P2','P4','P6','Pz'};
    % {'C5','C3','C1','C2','C4','C6','Cz','FC5','FC3','FC1','FC2','FC4','FC6','FCz','CP5','CP3','CP1','CP2','CP4','CP6','CPz'};

    chan_file = load('Biosemi_channels.mat');
    chan_names = getfield(chan_file,strcat('biosemi',num2str(biosemi_cfg)));
    biosemi_channels = fieldnames(chan_names);
    if select_all_channel
        selected_channels = biosemi_channels;
        selected_channels{biosemi_cfg+1} = 'EX1';
        selected_channels{biosemi_cfg+2} = 'EX2';
        if artifact_correction
            selected_channels{biosemi_cfg+3} = 'EX3';
            selected_channels{biosemi_cfg+4} = 'EX4';
            selected_channels{biosemi_cfg+5} = 'EX5';
            selected_channels{biosemi_cfg+6} = 'EX6';
            selected_channels{biosemi_cfg+7} = 'EX7';
            selected_channels{biosemi_cfg+8} = 'EX8';
        end

    else
        selected_channels = cell(1,length(wanted_channels));
        channel_indices = zeros(1,length(wanted_channels));
        for i = 1:length(wanted_channels)
            for j = 1:length(biosemi_channels)
                if strcmp(getfield(chan_names,biosemi_channels{j}),wanted_channels{i})
                    selected_channels{i} = biosemi_channels{j};
                    channel_indices(i) = j;
                end
            end
        end
        selected_channels{end+1} = 'EX1';
        selected_channels{end+1} = 'EX2';
        if artifact_correction
            selected_channels{end+1} = 'EX3';
            selected_channels{end+1} = 'EX4';
            selected_channels{biosemi_cfg+5} = 'EX5';
            selected_channels{biosemi_cfg+6} = 'EX6';
            selected_channels{biosemi_cfg+7} = 'EX7';
            selected_channels{biosemi_cfg+8} = 'EX8';
        end
    end

    %% Training
    for i = 1:length(files)
        disp(pwd)
        dataset = io_loadset(strcat(data_path,files{i},'.xdf'));
        if i == 1
            data = dataset;
        else
            data = set_concat(data,dataset);
        end
    end

    % window parameters, results are computed for windows of length
    % "windowlength", taken at steps "step" in the range "bounds" with respect
    % to the markers
    windowlength = 1;
    step = 0.2;
    bounds = [0 3];
    approach = {'FBCSP', ...
        'SignalProcessing',{ ...
        'Resampling','off', ...{'SamplingRate',128}, ...
        'ChannelSelection',{'Channels',selected_channels}, ...
        'Rereferencing',{'ReferenceChannels',{'EX1','EX2'},'KeepReference',false}, ...
        'FIRFilter','off', ...
        'EpochExtraction',{'TimeWindow',bounds}, ...
        }, ...
        'Prediction',{ ...
        'FeatureExtraction',{'PatternPairs',1,'FreqWindows',[8 12;13 30],'WindowFunction','rect'}, ...
        'MachineLearning',{'Learner',{'lda','WeightedBias',true,'WeightedCov',true}}} ...
        };
    [trainloss,model,stats] = train_automatic_window(data,approach,markers,windowlength,step);
    disp(['training mis-classification rate: ' num2str(trainloss*100,3) '%']);
    bci_visualize(model,'patterns',true,'weight_scaled',true)
    io_save(strcat(model_path,files{end},'_model'),'trainloss','model','stats');
    disp(strcat(['Filename: ''',files{end},'_model','''']))

end