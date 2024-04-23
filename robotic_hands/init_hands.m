function [hands, config] = init_hands()
    % Initialize the robotic hands
    % com: COM port to connect to the hands
    % 
    % Returns:
    % hands: arduino object
    % config: hands configuration

    % Load the hands configuration
    config = readstruct('hands_config.json');
    com = config.port;

    % Connect to the hands
    hands = arduino(com);
end