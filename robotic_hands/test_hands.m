function test_hands()
    % Test the robotic hands

    [hands, config] = init_hands();
    for i = 1:length(config.hands)
        hand = config.hands(i);
        for j = 1:length(hand.fingers)
            finger = hand.fingers(j);
            s = servo(hands, finger.pin, 'MinPulseDuration', 2e-3, 'MaxPulseDuration', 4e-3);
            s.writePosition(abs(finger.tension));
            pause(1);
            s.writePosition(abs(finger.tension - 1));
            pause(1);
        end
    end
    clear hands;
end