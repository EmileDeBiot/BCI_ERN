function deactivate(hands)
    % Deactivate the fingers (servomotors)
    % hands: serialport object
    write(hands, 'd', "char");
    disp(readline(hands));
end