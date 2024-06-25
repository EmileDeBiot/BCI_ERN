function hands = init_hands()
    % Initialize the robotic hands
    % 
    % Returns:
    % hands: serial port object

    % Load the hands configuration
    config = readstruct('hands_config.json');
    com = config.port;
    baudrate = config.baudrate;

    % Connect to the hands
    hands = serialport(com, baudrate, 'Timeout', 1);
end