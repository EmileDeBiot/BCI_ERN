function test_activation(com)
    [hands, config]  = init_hands(com);
    activate(hands, config, 'left', 2);
    activate(hands, config, 'right', 2);
    clear hands;
end





