function get_online_accuracy(markers, threshold, file)
    % get_online_accuracy: Get the accuracy of the online prediction
    %   markers: The markers to use
    %   threshold: The threshold for the feedback
    %   file: The file containing the data
    data_path = 'data/data/';
    
    thresholds = [0 threshold 1];
    init_bci();
    data = exp_eval(io_loadset(strcat(data_path,file,'.xdf')));
    streams = load_xdf(env_translatepath(strcat(data_path,file,'.xdf')));
    
    for i = 1:length(streams)
        if strcmp(streams{i}.info.type,'MentalState')
            prediction = streams{i}.time_series;
            prediction_latencies = streams{i}.time_stamps;
        end
    end

    prediction = prediction - 1;
    prediction_processed = prediction;
    state = 0;
    
    %courbe noire
    for i = 2:length(prediction_processed)           
        if ~state && prediction_processed(i) >=  thresholds(3)
            state = ~state;
            prediction_processed(i) = 1;
        elseif state && prediction_processed(i) <= thresholds(1)
            state = ~state;
            prediction_processed(i) = 0;
        else
            prediction_processed(i) = prediction_processed(i-1);
        end
    end
    targets = zeros(1,data.pnts);

    %courbe rouge
    for i = 1:length(data.event)
        if strcmp(data.event(i).type, markers(2))
            targets(round(data.event(i).latency):end) = 1;
        else
            targets(round(data.event(i).latency):end) = 0;
        end
    end

    prediction_lat = round((prediction_latencies-str2double(streams{3}.info.first_timestamp))*data.srate);        
    try 
        targets = targets(prediction_lat);
    catch
        targets = targets(prediction_lat(find(prediction_lat>0,1):end));
        prediction = prediction(find(prediction_lat>0,1):end);
        prediction_processed = prediction_processed(find(prediction_lat>0,1):end);
        warning('First %d negative timestamp(s) was/were removed', find(prediction_lat>0,1)-1);
    end
    cd BCILAB-master\BCILAB-master\dependencies\eeglab_10_0_1_0x\plugins\Biosig3.1.0;
    biosig_installer;
    k = kappa(round(targets),round(prediction));
    c = xcorr(targets,prediction);
    delay = min(abs(find(c==max(c))-length(prediction)))*mean(diff(prediction_latencies));
    k_processed = kappa(round(targets),round(prediction_processed));
    c_processed = xcorr(targets,prediction);
    delay_processed = min(abs(find(c_processed==max(c_processed))-length(prediction_processed)))*mean(diff(prediction_latencies));
    cd ../../../../../..;
    p = which('kappa');
    rmpath(genpath(p(1:end-17)));
    disp('Raw: ')
    disp(['    Accuracy: ',num2str(k.ACC)]);
    disp(['    Delay: ',num2str(delay)]);
    disp(['    Number of activation: ',num2str(length(find(diff(round(prediction))==1)))]);
    disp('Processed: ')
    disp(['    Accuracy: ',num2str(k_processed.ACC)]);
    disp(['    Delay: ',num2str(delay_processed)]);
    disp(['    Number of activation: ',num2str(length(find(diff(round(prediction_processed))==1)))]);
    figure;
    plot(1:length(targets),targets,'r',1:length(targets),prediction,'b',1:length(targets),prediction_processed,'k');
end