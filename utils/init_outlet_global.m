function [outlet, opts] = init_outlet_global(varargin)

    persistent lib;
    
    
	declare_properties('name','Lab streaming layer');
    
    opts = arg_define(varargin, ...
        arg({'global_pred_model','GlobalModel'}, 'lastmodel', [], 'Predictive model. As obtained via bci_train or the Model Calibration dialog.','type','expression'), ...
        arg({'in_stream','SourceStream'}, 'laststream',[],'Input Matlab stream. This is the stream that shall be analyzed and processed.'), ...
        arg({'out_stream','LabStreamName','Target'},'bci',[],'Name of the lab stream. This is the name under which the stream is provided to the lab streaming layer.'), ...
        arg({'channel_names','ChannelNames'},{'class1','class2'},[],'Output channel labels. These are the labels of the stream''s channels. In a typical classification setting each channel carries the probability for one of the possible classes.'), ...
        arg({'out_form','OutputForm','Form'},'mode',{'expectation','distribution','mode'},'Output form. Can be the expected value (posterior mean) of the target variable, or the distribution over possible target values (probabilities for each outcome, or parametric distribution), or the mode (most likely value) of the target variable.'), ...
        arg({'update_freq','UpdateFrequency'},10,[],'Update frequency. This is the rate at which the output is updated.'), ...
        arg({'predict_at','PredictAt'}, {},[],'Predict at markers. If nonempty, this is a cell array of online target markers relative to which predictions shall be made. If empty, predictions are always made on the most recently added sample.','type','expression'), ...
        arg({'verbose','Verbose'}, false,[],'Verbose output. If false, the console output of the online pipeline will be suppressed.'), ...
        arg({'source_id','SourceID'}, 'input_data',{'input_data','model'},'Use as source ID. This is the data that determines the source ID of the stream (if the stream is restarted, readers will continue reading from it if it has the same source ID). Can be input_data (use a hash of dataset ID + target markers used for training) or model (use all model parameters).'), ...
        arg({'pred_name','PredictorName'}, 'lastpredictor',[],'Name of new predictor. This is the workspace variable name under which a predictor will be created.'));

    
    % load the models
    global_model = utl_loadmodel(opts.global_pred_model);
    
    % check if channel labels make sense for the models
    if strcmp(opts.out_form,'distribution')
        if isfield(global_model,'classes') && ~isempty(global_model.classes)
            if length(opts.channel_names) ~= length(global_model.classes)
                disp('The number of classes provided by the global model does not match the number of provided channel names; falling back to default names.');
                opts.channel_names = cellfun(@(k)['class' num2str(k)],num2cell(1:length(global_model.classes),1),'UniformOutput',false);
            end
        end
    else
        if isfield(global_model,'classes') && ~isempty(global_model.classes)
            if length(opts.channel_names) ~= 1
                disp('A classification global model will produce just one channel if the output is not in distribution form, but a different number of channels was given. Falling back to the default channel label.');
                opts.channel_names = {'class'};
            end        
        end
    end
    
    % try to calculate a UID for the stream

    try
        if strcmp(opts.source_id,'input_data')
            uid = hlp_cryptohash({global_model.source_data,opts.predict_at,opts.in_stream,opts.out_stream});
        else
            error('Unsupported SourceID option: %s',hlp_tostring(opts.source_id));
        end
    catch e
        disp('Could not generate a unique ID for the predictive model; the BCI stream will not be recovered automatically after the provider system had a crash.');
        hlp_handleerror(e);
        uid = '';
    end
    
    % instantiate the library
    disp('Opening the library...');
    if isempty(lib)
        lib = lsl_loadlib(env_translatepath('dependencies:/liblsl-Matlab/bin')); end

    % describe the stream
    disp('Creating a new streaminfo...');
    info = lsl_streaminfo(lib,opts.out_stream,'MentalState',length(opts.channel_names),opts.update_freq,'cf_float32',uid);
    % ... including some meta-data
    desc = info.desc();
    channels = desc.append_child('channels');
    for c=1:length(opts.channel_names)
        newchn = channels.append_child('channel');
        newchn.append_child_value('name',opts.channel_names{c});
        newchn.append_child_value('type',opts.out_form);
    end
    
    % create an outlet
    outlet = lsl_outlet(info);
end
