function activate(hands, config, side, finger)
    % Activate the robotic hand
    % hands: arduino object
    % config: hands configuration
    % side: 'left' or 'right'
    % finger: [1, 2, 3, 4, 5]

    if strcmp(side, 'left')
        hand = config.hands(2);
    else
        hand = config.hands(1);
    end

    finger = hand.fingers(finger);

    % Activate the finger
    servo = servo(hands, finger.pin, 'MinPulseDuration', 2e-3, 'MaxPulseDuration', 4e-3);
    servo.writePosition(abs(left_finger.tension-0.8));
    pause(1);
    servo.writePosition(abs(left_finger.tension - 1));
end