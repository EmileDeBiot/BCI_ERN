data_path = 'data/data/';
stream = eeg_load_xdf(strcat(data_path, 'P1_HR_T1.xdf'), 'streamname', 'BioSemi');

stream_compare = eeg_load_xdf(strcat(data_path, 'P1_HB_T1.xdf'), 'streamname', 'BioSemi');
latencies = [];
for i = 1:length(stream.event)
    if strcmp(stream_compare.event(i).type, 'cross')
        latencies = [latencies stream.event(i).latency];
    end
end
eeg = eeg_addnewevents(stream_compare, {latencies}, {'rest'});