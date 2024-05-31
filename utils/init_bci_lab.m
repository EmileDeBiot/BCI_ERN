function init_bci_lab()
    % init_bci: Load BCILAB if it is not already loaded
    if isempty(which('bci_train.m'))
        data_path = 'data/data/';
        disp('Loading BCILAB...')
        %cd BCILAB-master/BCILAB-master;
        cd BCILAB;
        bcilab('data',data_path,'menu',false,'mem_capacity',0.5);
        cd ..;
        cd ..;
        disp('BCILAB loaded!')
    else 
        disp('BCILAB already loaded!')
    end
end