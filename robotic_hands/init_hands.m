function hands = init_hands()
    % Initialize the robotic hands
    % 
    % Returns:
    % hands: arduino object

    % Load the hands configuration
    config = readstruct('hands_config.json');
    com = config.port;
    baudrate = config.baudrate;

    % Connect to the hands
    hands = serialport(com, baudrate);
    disp(read(hands, 50, "char"));
end