delete(instrfind);

clear  % supprime toutes les variabls creees precedemment
close all % ferme toutes les fenetres ouvertes precedemment

data_path = 'data/data/';
model_path = 'data/models/';
result_path = 'data/results/';
resource_path = 'data/resources/';
left_model_file = 'left_test_model';
right_model_file = 'right_test_model';

threshold = 0.5;

cap = 64;
prediction_frequency = 10;

NomExperience = 'RoboticHand';

%% Init BCI
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
disp('The BioSemi is linked to LSL');

% Open recorder
cd LabRecorder
system('LabRecorder.exe -c my_config.cfg &');
cd ..;

%% Visualization
vis_stream('BioSemi',10,5,150,1:1+cap+8,100,10);

%% Loading files
disp('Loading models...')
left_file = io_load(strcat(model_path,left_model_file));
left_model = left_file.model;

right_file = io_load(strcat(model_path,right_model_file));
right_model = right_file.model;

disp('Starting the outlet...')
[eeg_outlet,  opts] = init_outlet('LeftModel',left_model, 'RightModel', right_model, 'SourceStream','BioSemi','LabStreamName','BCI','OutputForm','expectation','UpdateFrequency',prediction_frequency);

disp('Initializing the robotic hands...')
[hands, config] = init_hands('COM12');

disp('Initializing marker stream...')
info = lsl_streaminfo(LibHandle,'MyMarkerStream','Markers',1,0,'cf_string','myuniquesourceid23443');
marker_outlet = lsl_outlet(info);


%% Port EEG

SsNum = input ('Participant''s number:  ','s');
age = input ('Age: ', 's');

% % nom du fichier de sortie
fileNamePs = strcat(result_path, NomExperience, '_Participant_', SsNum, '.txt');


%% ETAPE 1: OUVRERTURE DE LA PTB


Screen('Preference', 'SkipSyncTests', 0);
w=Screen('OpenWindow',2);

cycleRefresh=Screen('GetFlipInterval', w);

vbl=Screen(w, 'Flip');
[width, height]=Screen('WindowSize', w);

% cr�ation des objets pour enregistrement des data
dataStr = {};
dataNum = [];
touche = {};
Expe = [];

Decision = imread(strcat(resource_path,'Decision.jpg'));
Action = imread(strcat(resource_path,'Action.jpg'));
Good_1 = imread(strcat(resource_path,'Good_1.jpg'));
Good_2 = imread(strcat(resource_path,'Good_2.jpg'));
Bad_1 = imread(strcat(resource_path,'Bad_1.jpg'));
Bad_2 = imread(strcat(resource_path,'Bad_2.jpg'));
Controle = imread(strcat(resource_path,'Controle_09.jpg'));

KbName('UnifyKeyNames');

% lancer les pr�dicitons 
onl_write_background2( ...
    'ResultWriter',@(y1, y2)send_samples(eeg_outlet, hands, config, threshold, y1, y2),...
    'MatlabStream',opts.in_stream, ...
    'LeftModel',left_model, ...
    'RightModel', right_model, ...
    'OutputFormat',opts.out_form, ...
    'UpdateFrequency',opts.update_freq, ...
    'PredictorName',opts.pred_name, ...
    'PredictAt',opts.predict_at, ...
    'Verbose',opts.verbose, ...
    'StartDelay',0,...
    'EmptyResultValue',[]);

for BLOCK=1
    %% Temps random croix de fixation
    ITI=random('unif',1.5,2.3,60,1)';
    
    %% Liste avecalternance entre Outcome 1 et 2 (r�ponse correct ou incorrect, � gauche ou � droite)
    %% 1=r�ponse correcte / 2 = r�ponse incorrecte
    mapping=[1,2];
    mapping_number=repmat(mapping,1,60);
    order=randperm(60);
    mapping_number=mapping_number(order);
    mapping_list=[mapping_number];
    nMapping=(mapping_list);
    
    ListEXPE = [ITI; mapping_list];
    nEXPE=length(ListEXPE);
    
    %for k=1:length(ListEXPE(1,:))
    for k=1:10
                
        %% Choix Gauche ou droite %%
        Screen('Putimage', w, Decision);
        Screen('Flip', w);
        
        while true
            [secs, keyCode, deltaSecs] = KbWait;
            WaitSecs(0.2);
            if keyCode(KbName('LeftArrow'))
                DECISION=1;
                break;
            elseif keyCode(KbName('RightArrow'))
                DECISION=2;
                break;
            end
        end

        WaitSecs(1);

        Screen('Putimage', w, Action);
        Screen('Flip', w);
        
        while true
            [secs, keyCode, deltaSecs] = KbWait;
            WaitSecs(0.2);
            if strcmp(KbName(keyCode),'x') || strcmp(KbName(keyCode),'n')
                break;
            end
        end

        %% Outcome %%
        
        if strcmp(KbName(keyCode),'x') && ListEXPE(2,k)==1
            Screen('Putimage', w, Good_1);
            Screen('Flip', w);
            WaitSecs(1);
            OUTCOME= 'ToucheGauche_Good';
            marker_outlet.push_sample({num2str(120)}); %% TRIGGER EEG
        elseif strcmp(KbName(keyCode),'x') && ListEXPE(2,k)==2
            Screen('Putimage', w, Bad_1);
            Screen('Flip', w);
            WaitSecs(1);
            OUTCOME='ToucheGauche_Bad';
            marker_outlet.push_sample({num2str(150)}); %% TRIGGER EEG
        elseif strcmp(KbName(keyCode),'n') && ListEXPE(2,k)==1
            Screen('Putimage', w, Good_2);
            Screen('Flip', w);
            WaitSecs(1);
            OUTCOME='ToucheDroite_Good';
            marker_outlet.push_sample({num2str(122)}); %% TRIGGER EEG
        elseif strcmp(KbName(keyCode),'n') && ListEXPE(2,k)==2
            Screen('Putimage', w, Bad_2);
            Screen('Flip', w);
            WaitSecs(1);
            OUTCOME='ToucheDroite_Bad';
            marker_outlet.push_sample({num2str(155)}); %% TRIGGER EEG
        end
        
        %% Fixation cross %%
        DrawFormattedText(w, '+','center','center');
        Screen('Flip', w);
        WaitSecs(ListEXPE(1,k));
        
        %% Feeling in control %%
        %replyControle = Ask(w,'Le mouvement observ� �tait d� � ma propre volont� (R�ponse de 0 � 10): ', white, grey, 'GetChar',[150, 550, 200, 300],[],22);
        Screen('Putimage', w, Controle);
        Screen('Flip', w);
        
        while true
            [secs, keyCode, deltaSecs] = KbWait;
            WaitSecs(0.2);
            num = str2double(KbName(keyCode));
            if ~isnan(num) && isnumeric(num)
                replyControle = num;
                break;
            end
        end
        
        WaitSecs(1);
        
        %% RESULTS
        
        dataNum(k,1) = str2num(SsNum);
        dataNum(k,2) = k;
        
        dataStr{k,1} = age;
        dataStr{k,2} = num2str(DECISION);
        dataStr{k,3} = OUTCOME;
        dataStr{k,4} = num2str(replyControle);
        
        dataExp = [num2cell(dataNum), dataStr];
        dataExp = dataExp';
        
        fid = fopen(fileNamePs, 'wt');
        fprintf(fid, '%s\t%s\t%s\t%s\t%s\t%s\n',...
            'NumeroParticipant', 'NumeroEssai', 'age', 'Decision', 'Outcome', 'ReplyControle');
        fprintf(fid, '%f\t%f\t%s\t%s\t%s\t%s\n', dataExp{:});
        fclose(fid);
                
    end
    dlmwrite([result_path 'P' SsNum NomExperience '.txt'],ListEXPE,'delimiter',',');
    clear ListEXPE
    
end


Screen('CloseAll');


function send_samples(outlet, hands, config,threshold,y1, y2)
    if ~isempty(y1) && ~isempty(y2)
        outlet.push_chunk(y1');
        outlet.push_chunk(y2');
        if (y1-1) >= threshold && (y2-1) >= threshold
            disp('Both hands activated');
            activate(hands, config, 'left', 2);
            activate(hands, config, 'right', 2);
        elseif (y1-1) >= threshold
            disp('Left hand activated');
            activate(hands, config, 'left', 2);
        elseif (y2-1) >= threshold
            disp('Right hand activated');
            activate(hands, config, 'right', 2);
        end
    end
end                  
