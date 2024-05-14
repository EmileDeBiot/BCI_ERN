% Load xdf files and transform them to bdf

function xdf2bdf(xdf_file)
    data_path = 'data/data/';
    result_path = 'data/results/';
    eeg = eeg_load_xdf(strcat(data_path,xdf_file));
    labels = {};
    for i = 2:73
        labels = [labels, {eeg.chanlocs(i).labels}];
    end
    eeg_data = eeg.data(2:73, :);
    trigger_data = eeg.data(1, :);
    filename = strcat(result_path, xdf_file(1:length(xdf_file)-4), '.bdf');
    f = writeeeg(filename(1:length(filename) - 4), eeg_data, eeg.srate, 'label', labels, 'TYPE', 'BDF');
    t = writeeeg(strcat(filename, '_trigger.bdf'), trigger_data, eeg.srate, 'label', {'Trigger'}, 'TYPE', 'BDF');
end

