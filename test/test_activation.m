function test_activation()
    hands  = init_hands();
    action(hands, 1);
    pause(1);
    action(hands, 2);
    pause(1);
    deactivate(hands);
    pause(0.5);
    % Testing if the action is possible when deactivated: should do nothing
    action(hands, 1);
    pause(1);
    action(hands, 2);
    clear hands;
end





