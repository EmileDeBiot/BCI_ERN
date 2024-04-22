function [hands, config] = init_hands(com)
    % Initialize the robotic hands
    % com: COM port to connect to the hands
    % 
    % Returns:
    % hands: arduino object
    % config: hands configuration

    % Load the hands configuration
    config = load('hands_config.json');

    % Check if the com port is available
    if ~isempty(instrfind('Type', 'serial', 'Port', com))
        fclose(instrfind('Type', 'serial', 'Port', com));
        delete(instrfind('Type', 'serial', 'Port', com));
    end

    % Connect to the hands
    hands = arduino(com);
end