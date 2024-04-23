function test_activation()
    [hands, config]  = init_hands();
    activate(hands, config, 'left', 2);
    activate(hands, config, 'right', 2);
    clear hands;
end





