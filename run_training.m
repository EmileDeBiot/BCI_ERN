clear;
addpath("utils\")
addpath("robotic_hands\")
% Valeurs initiales
params = struct('ID', 'P1_HR_T1', ...
                'previousModel', '', ...
                'previousModel2', '', ...
                'testedHand', 'right', ...
                'nbTrialsPerHand', 20, ...
                'crossDelay', 3000, ...
                'arrowDelay', 3000, ...
                'imaginationDelay', 2000, ...
                'restDelay', 0, ...
                'predictionFrequency', 10, ...
                'files', '', ...
                'threshold', 0.5, ...
                'file', '', ...
                'threshold2', 0.8, ...
                'modelFile', '',...
                'otherFile', '');
            

open_window_1(params);

function open_window_1(params)
    % Cr�ation de la fen�tre principale
    f = uifigure('Name', 'Experience parameters', 'Position', [200, 200, 840, 220], 'Resize', 'off');
    
    % Cr�ation des labels
    uilabel(f, 'Text', 'ID: ', 'Position', [10, 195, 100, 20]);
    uilabel(f, 'Text', 'Previous Model: ', 'Position', [10, 160, 90, 20]);
    uilabel(f, 'Text', 'Tested hand', 'Position', [10, 135, 80, 20]);
    uilabel(f, 'Text', 'Nb trial per hand', 'Position', [5, 55, 90, 20]);
    uilabel(f, 'Text', 'Cross delay:', 'Position', [110, 135, 100, 20]);
    uilabel(f, 'Text', 'Arrow delay:', 'Position', [110, 110, 100, 20]);
    uilabel(f, 'Text', 'Imagination delay:', 'Position', [110, 85, 100, 20]);
    uilabel(f, 'Text', 'Rest delay:', 'Position', [110, 60, 100, 20]);
    uilabel(f, 'Text', 'Prediction frequency:', 'Position', [109, 35, 102, 20]);
    uilabel(f, 'Text', 'Files:', 'Position', [335, 165, 80, 20]);
    uilabel(f, 'Text', 'Threshold:', 'Position', [450, 165, 80, 20]);
    uilabel(f, 'Text', 'File:', 'Position', [450, 140, 80, 20]);
    uilabel(f, 'Text', 'Threshold:', 'Position', [650, 165, 80, 20]);
    uilabel(f, 'Text', 'Model file:', 'Position', [650, 140, 80, 20]);
    uilabel(f, 'Text', 'Other file:', 'Position', [650, 115, 80, 20], 'Visible', 'Off');
    
    % Cr�ation des zones de texte
    eFiles                 = uitextarea(f, 'Position', [320, 35, 110, 130], 'Value', params.files,'Editable', 'Off');
    eID                    = uitextarea(f, 'Position', [110, 195, 180, 20], 'Value', params.ID);
    ePreviousModel         = uitextarea(f, 'Position', [120, 165, 180, 20], 'Value', params.previousModel );
    eNbTrialsPerHand       = uitextarea(f, 'Position', [10, 35, 80, 20], 'Value', num2str(params.nbTrialsPerHand));
    eCrossDelay            = uitextarea(f, 'Position', [220, 135, 80, 20], 'Value', num2str(params.crossDelay));
    eArrowDelay            = uitextarea(f, 'Position', [220, 110, 80, 20], 'Value', num2str(params.arrowDelay));
    eImaginationDelay      = uitextarea(f, 'Position', [220, 85, 80, 20], 'Value', num2str(params.imaginationDelay));
    eRestDelay             = uitextarea(f, 'Position', [220, 60, 80, 20], 'Value', num2str(params.restDelay));
    ePredictionFrequency   = uitextarea(f, 'Position', [220, 35, 80, 20], 'Value', num2str(params.predictionFrequency));
    eThreshold             = uitextarea(f, 'Position', [550, 165, 80, 20], 'Value', num2str(params.threshold));
    eFile                  = uitextarea(f, 'Position', [550, 140, 80, 20], 'Value', params.file);
    eThreshold2            = uitextarea(f, 'Position', [750, 165, 80, 20], 'Value', num2str(params.threshold2));
    eModelFile             = uitextarea(f, 'Position', [710, 140, 120, 20], 'Value', params.modelFile);
    eOtherFile             = uitextarea(f, 'Position', [710, 115, 120, 20], 'Value', params.otherFile, 'Visible', 'Off');
    
    % Cr�ation des boutons radio
    bTestedHand = uibuttongroup(f, 'Position', [10, 80, 80, 56]);
    if strcmp(params.testedHand, 'right')
        vbRight = true;
        vbLeft = false;
        vbBoth = false;
    elseif strcmp(params.testedHand, 'left')
        vbRight = false;
        vbLeft = true;
        vbBoth = false;
    else
        vbRight = false;
        vbLeft = false;
        vbBoth = true;
    end
    
    bRight      = uiradiobutton(bTestedHand, 'Position', [5, 38, 70, 19], 'Text', 'Right', 'Value', vbRight);
    bLeft       = uiradiobutton(bTestedHand, 'Position', [5, 19, 70, 19], 'Text', 'Left', 'Value', vbLeft);
    bBoth       = uiradiobutton(bTestedHand, 'Position', [5, 0, 70, 19], 'Text', 'Both', 'Value', vbBoth);
    
    % Cr�ation des boutons
    bTrainingSession = uibutton(f, 'push', 'Text', 'Training Session', 'Position', [105, 5, 100, 20]);
    set(bTrainingSession, 'ButtonPushedFcn', {@cbTrainingSession, ...
                                       f, ...
                                       eID, ...
                                       ePreviousModel, ...
                                       eNbTrialsPerHand, ...
                                       eCrossDelay, eArrowDelay, eImaginationDelay, eRestDelay, ...
                                       ePredictionFrequency, ...
                                       bRight, bLeft, bBoth, ...
                                       eFiles, ...
                                       eThreshold, ...
                                       eFile,...
                                       eThreshold2,...
                                       eModelFile,...
                                       eOtherFile});
    bTrainingModel = uibutton(f, 'push', 'Text', 'Training Model', 'Position', [330, 5, 90, 20]);
    set(bTrainingModel, 'ButtonPushedFcn', {@cbTrainingModel, ...
                                     f, ...
                                     eID, ...
                                     ePreviousModel, ...
                                     eNbTrialsPerHand, ...
                                     eCrossDelay, eArrowDelay, eImaginationDelay, eRestDelay, ...
                                     ePredictionFrequency, ...
                                     bRight, bLeft, bBoth, ...
                                     eFiles, ...
                                     eThreshold, ...
                                     eFile, ...
                                     eThreshold2,...
                                     eModelFile,...
                                     eOtherFile});

    bGetOnlineAccuracy = uibutton(f, 'push', 'Text', 'Get Online Accuracy', 'Position', [480, 5, 120, 20]);
    set(bGetOnlineAccuracy, 'ButtonPushedFcn', {@cbGetOnlineAccuracy, ...
                                                 bRight, bLeft, bBoth, ...
                                                 eThreshold, ...
                                                 eFile});
    bFeedbackSession = uibutton(f, 'push', 'Text', 'Feedback Session', 'Position', [680, 5, 120, 20]);
    set(bFeedbackSession, 'ButtonPushedFcn', {@cbFeedbackSession, ...
                                               eThreshold2, ...
                                               eModelFile,...
                                               bRight, bLeft, bBoth});

    bUpdate = uibutton(f, 'push', 'Text', 'Update', 'Position', [335, 195, 80, 20]);
    set(bUpdate, 'ButtonPushedFcn', {@cbUpdate, ...
                                      eID, ...
                                      ePreviousModel, ...
                                      bRight, bLeft, bBoth, ...
                                      eFiles, ...
                                      eFile, ...
                                      eModelFile, ...
                                      eOtherFile});
    
                          
    % S�parateurs
    uipanel(f, 'Position', [0, 29, 840, 2], 'BorderType', 'none', 'BackgroundColor','Black');
    uipanel(f, 'Position', [0, 159, 102, 1], 'BorderType', 'none', 'BackgroundColor','Black');
    uipanel(f, 'Position', [0, 189, 840, 2], 'BorderType', 'none', 'BackgroundColor','Black');
    uipanel(f, 'Position', [100, 29, 2, 130], 'BorderType', 'none', 'BackgroundColor','Black');
    uipanel(f, 'Position', [310, 0, 2, 190], 'BorderType', 'none', 'BackgroundColor','Black');
    uipanel(f, 'Position', [440, 0, 2, 190], 'BorderType', 'none', 'BackgroundColor','Black');
    uipanel(f, 'Position', [640, 0, 2, 190], 'BorderType', 'none', 'BackgroundColor','Black');
end

% Fonction de callback du bouton start
function cbTrainingSession(~, ~, f, eID, ePreviousModel, eNbTrialsPerHand, eCrossDelay, eArrowDelay, eImaginationDelay, eRestDelay, ePredictionFrequency, bRight, bLeft, bBoth, eFiles, eThreshold, eFile, eThreshold2, eModelFile, eOtherFile)
    % Start the training session
    % Inputs:
    %   ~: unused
    %   ~: unused
    %   f: figure
    %   eID: ID of the session
    %   ePreviousModel: previous model
    %   eNbTrialsPerHand: number of trials per hand
    %   eCrossDelay: delay between the cross and the arrow
    %   eArrowDelay: delay between the arrow and the imagination
    %   eImaginationDelay: delay between the imagination and the rest
    %   eRestDelay: delay between the rest and the cross
    %   ePredictionFrequency: prediction frequency
    %   bRight: right hand radiobutton
    %   bLeft: left hand radiobutton
    %   bBoth: both hands radiobutton
    %   eFiles: files
    %   eThreshold: threshold
    %   eFile: file
    %   eThreshold2: threshold 2
    %   eModelFile: model file
    %   eOtherFile: other file
    
    data_path = 'data/data/';  
    % V�rification des param�tres + sauvegarde
    num = str2double(get(eNbTrialsPerHand, 'Value'));
    if isnan(num) || ~isnumeric(num) || num <= 0 || mod(num, 1)~=0
        disp('Param�tre [Nb Trials Per Hand] incorrect')
        return;
    end
    params.nbTrialsPerHand = num;
    
    
    num = str2double(get(eCrossDelay, 'Value'));
    if isnan(num) || ~isnumeric(num) || num < 0
        disp('Param�tre [Cross Delay] incorrect')
        return;
    end
    params.crossDelay = num;
    
    num = str2double(get(eArrowDelay, 'Value'));
    if isnan(num) || ~isnumeric(num) || num < 0
        disp('Param�tre [Arrow Delay] incorrect')
        return;
    end
    params.arrowDelay = num;
    
    num = str2double(get(eRestDelay, 'Value'));
    if isnan(num) || ~isnumeric(num) || num < 0
        disp('Param�tre [Rest Delay] incorrect')
        return;
    end
    params.restDelay = num;
    
    num = str2double(get(eImaginationDelay, 'Value'));
    if isnan(num) || ~isnumeric(num) || num < 0
        disp('Param�tre [Imagination Delay] incorrect')
        return;
    end
    params.imaginationDelay = num;
    
    num = str2double(get(ePredictionFrequency, 'Value'));
    if isnan(num) || ~isnumeric(num) || num <= 0
        disp('Param�tre [Prediction Frequency] incorrect')
        return;
    end
    params.predictionFrequency = num;
    
    params.ID = char(get(eID, 'Value'));
    if isempty(regexp(params.ID, '^P\d+_H[RLB]_T\d+$', 'once'))
        disp('Mauvais format d''[ID]. Suivez le format ''Px_Hy_Tz''');
        return;
    end
    
    params.previousModel = string(get(ePreviousModel, 'Value'));
    if get(bRight, 'Value')
        params.testedHand = 'right';
    elseif get(bLeft, 'Value')
        params.testedHand = 'left';
    elseif get(bBoth, 'Value')
        params.testedHand = 'both';
    end
    
    
    
    params.threshold               = str2double(get(eThreshold, 'Value'));
    params.file                    = get(eFile, 'Value');
    params.threshold2              = str2double(get(eThreshold2, 'Value'));
    params.modelFile               = get(eModelFile, 'Value');
    params.otherFile               = get(eOtherFile, 'Value');
    
    
    close(f);
    disp('Training Session');
    training_session(params.previousModel, params.testedHand, params.nbTrialsPerHand, params.crossDelay, params.arrowDelay, params.imaginationDelay, params.restDelay, params.predictionFrequency);

    % Mise � jour des fichiers utilis�s pour le training model
    matchResult = regexp(params.ID, '.*_.*_T(\d+)', 'tokens');
    if ~isempty(matchResult)
        zValue = str2double(matchResult{1}{1});
        iterations = cell(zValue, 1);
        for i = 1:zValue
            iterationStr = strrep(params.ID, ['T', num2str(zValue)], ['T', num2str(i)]);
            if exist(strcat(data_path,iterationStr,'.xdf'), 'file') == 2
                iterations{i} = iterationStr;
            else
                iterations{i} = '';
            end
        end
    else
        iterations = {};
    end
    params.files = iterations;

    open_window_1(params);
end

function cbTrainingModel(~, ~, f, eID, ePreviousModel, eNbTrialsPerHand, eCrossDelay, eArrowDelay, eImaginationDelay, eRestDelay, ePredictionFrequency, bRight, bLeft, bBoth, eFiles, eThreshold, eFile, eThreshold2, eModelFile, eOtherFile)
    data_path = 'data/data/';
    model_path = 'data/models/';
    % V�rification
    if strcmp(eFiles.Value, '')
        disp('Aucun fichiers disponibles');
        return;
    end
    % Sauvegarde des param�tres
    params.ID = char(get(eID, 'Value'));
    params.previousModel = get(ePreviousModel, 'Value');
    if get(bRight, 'Value')
        params.testedHand = 'right';
    elseif get(bLeft, 'Value')
        params.testedHand = 'left';
    elseif get(bBoth, 'Value')
        params.testedHand = 'both';
    end
    params.nbTrialsPerHand         = str2double(get(eNbTrialsPerHand, 'Value'));
    params.crossDelay              = str2double(get(eCrossDelay, 'Value'));
    params.arrowDelay              = str2double(get(eArrowDelay, 'Value'));
    params.imaginationDelay        = str2double(get(eImaginationDelay, 'Value'));
    params.restDelay               = str2double(get(eRestDelay, 'Value'));
    params.predictionFrequency     = str2double(get(ePredictionFrequency, 'Value'));
    params.files                   = get(eFiles, 'Value');
    params.threshold               = str2double(get(eThreshold, 'Value'));
    params.file                    = get(eFile, 'Value');
    params.threshold2              = str2double(get(eThreshold2, 'Value'));
    params.modelFile               = get(eModelFile, 'Value');
    params.otherFile               = get(eOtherFile, 'Value');

    
    close(f);
    disp('Training Model');
    training_model(params.testedHand, params.files);
    % Mise � jour des fichiers utilis�s pour le training model
    matchResult = regexp(params.ID, '.*_.*_T(\d+)', 'tokens');
    if ~isempty(matchResult)
        zValue = str2double(matchResult{1}{1});
    else
        zValue = 0;
    end

    % Mise � jour du previous model
    if zValue < 1
        params.previousModel = '';
    else
        params.previousModel = strcat(params.ID, '_model');
        if ~(exist(strcat(model_path,params.previousModel, '.mat'), 'file') == 2)
            params.previousModel = '';
        end
    end
    params.modelFile = params.previousModel;
    
    % Mise � jour du fichier utilis� pour l'accuracy
    if zValue <= 1
        params.file = '';
    else
        if exist(strcat(data_path,params.ID, '.xdf'), 'file') == 2
            params.file = params.ID;
        else
            params.file = '';
        end 
    end

    % Incr�mentation du num�ro de training
    params.ID = strrep(params.ID, ['T', num2str(zValue)], ['T', num2str(zValue + 1)]);
 
    
    open_window_1(params);
end
function cbGetOnlineAccuracy(~, ~, bRight, bLeft, bBoth, eThreshold, eFile)
    data_path = 'data/data/';
    % V�rification des param�tres
    if get(bRight, 'Value')
        params.testedHand = 'right';
    elseif get(bLeft, 'Value')
        params.testedHand = 'left';
    elseif get(bBoth, 'Value')
        params.testedHand = 'both';
    end
    
    num = str2double(get(eThreshold, 'Value'));
    if isnan(num) || ~isnumeric(num) || num < 0 || num > 1
        disp('Param�tre [Threshold] incorrect')
        return;
    end
    
    params.threshold = num;
    
    params.file = char(get(eFile, 'Value'));
    if ~(exist(strcat(data_path, params.file, '.xdf'), 'file') == 2)
        disp('Fichier introuvable');
        return;
    end

    disp('Get Online Accuracy');
    if strcmp(params.testedHand, 'both')
        markers = {'cross', 'right', 'left'};
    else
        markers = {'cross',params.testedHand};
    end
    
    get_online_accuracy(markers, params.threshold, params.file);
end

function cbFeedbackSession(~, ~, eThreshold2, eModelFile, bRight, bLeft, bBoth)
    model_path = 'data/models/';
    if get(bRight, 'Value')
        params.testedHand = 'right';
    elseif get(bLeft, 'Value')
        params.testedHand = 'left';
    elseif get(bBoth, 'Value')
        params.testedHand = 'both';
    end

    num = str2double(get(eThreshold2, 'Value'));
    if isnan(num) || ~isnumeric(num) || num < 0 || num > 1
        disp('Param�tre [Threshold] incorrect')
        return;
    end
    params.threshold2 = num;
    
    params.modelFile = char(get(eModelFile, 'Value'));
    if ~(exist(strcat(model_path, params.modelFile, '.mat'), 'file') == 2)
        disp('Fichier introuvable');
        return;
    end
  
    
    disp('Feedback session');
    feedback_session(params.threshold2, params.modelFile, params.testedHand);
end

function cbUpdate(~, ~, eID, ePreviousModel, bRight, bLeft, bBoth, eFiles, eFile, eModelFile, eOtherFile)
    data_path = 'data/data/';
    model_path = 'data/models/';
    params.ID = char(get(eID, 'Value'));
    if isempty(regexp(params.ID, '^P\d+_H[RLB]_T\d+$', 'once'))
        disp('Mauvais format d''[ID]. Suivez le format ''Px_Hy_Tz''');
        return;
    end
    
    % Mise � jour des fichiers utilis�s pour le training model
    matchResult = regexp(params.ID, '.*_.*_T(\d+)', 'tokens');
    if ~isempty(matchResult)
        zValue = str2double(matchResult{1}{1});
        iterations = cell(zValue, 1);
        for i = 1:zValue
            iterationStr = strrep(params.ID, ['T', num2str(zValue)], ['T', num2str(i)]);
            if exist(strcat(data_path, iterationStr, '.xdf'), 'file') == 2
                iterations{i} = iterationStr;
            else
                iterations{i} = '';
            end
        end
    else
        zValue = 0;
        iterations = {};
    end
    params.files = iterations;
    set(eFiles, 'Value', params.files);

    % Mise � jour de la main test�e
    matchResult = regexp(params.ID, 'P\d+_H([RLB])_T\d+', 'tokens');
    if ~isempty(matchResult)
        yValue = matchResult{1}{1};
    else
        yValue = '';
    end
    if yValue == 'R'
        bRight.Value = true;
        bLeft.Value = false;
        bBoth.Value = false;
    elseif yValue == 'L'
        bRight.Value = false;
        bLeft.Value = true;
        bBoth.Value = false;
    elseif yValue == 'B'
        bRight.Value = false;
        bLeft.Value = false;
        bBoth.Value = true;
    end

    % Mise � jour du fichier � utiliser pour obtenir l'accuracy = previous model
    if zValue > 0
        params.modelFile = strcat(params.ID, '_model');
        if ~(exist(strcat(model_path, params.modelFile, '.mat'), 'file') == 2)
            params.modelFile = '';
        end
    end
    if zValue <= 1
        params.file = '';
        params.previousModel = '';
    else
        if exist(strcat(data_path, params.ID, '.xdf'), 'file') == 2
            params.file = params.ID;
        else
            params.file = '';
        end 
        params.previousModel = strcat(strrep(params.ID, ['T', num2str(zValue)], ['T', num2str(zValue-1)]), '_model');
        if ~(exist(strcat(model_path, params.previousModel, '.mat'), 'file') == 2)
            params.previousModel = '';
        end
    end
    eFile.Value = params.file;
    ePreviousModel.Value = params.previousModel;
    eModelFile.Value = params.modelFile;
end