function [hands, config] = init_hands(com)
    % Initialize the robotic hands
    % com: COM port to connect to the hands
    % 
    % Returns:
    % hands: arduino object
    % config: hands configuration

    % Load the hands configuration
    hands = arduino(com);
    config = load('hands_config.json');
end