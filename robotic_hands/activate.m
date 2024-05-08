function activate(hands)
    % Activate the fingers (servomotors)
    % hands: serialport object

    write(hands, 'a', "char");
    disp(read(hands, 20, "char"));
end
